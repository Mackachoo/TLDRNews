"""TLDR Party membership approval.

A member proves they can see the private Party channel by naming the URL of a
video they were only given the title of. `request_video` picks the video and
hands back an HMAC of the answer; `approve` takes that URL and HMAC back.

The HMAC is keyed with a Secret Manager secret and bound to the caller's uid and
a single-use nonce, so a guess can only be tested by calling `approve`, a hash
issued to one account is worthless to another, and a correct pair cannot be
replayed. `meta/{uid}` is readable by any signed-in user, so the attempt record
holds the digest and never the video id.
"""

import hmac
import logging
import re
from datetime import datetime, timedelta, timezone
from hashlib import sha256
from secrets import choice, token_hex

from ..utils import firebase_client as fb

PARTY_CID = 'party'

WINDOW_DAYS = 14
MAX_GUESSES = 3
KEEP_ATTEMPTS = 20
MEMBERSHIP_DAYS = 90

EPOCH = datetime(1970, 1, 1, tzinfo=timezone.utc)

VIDEO_URL = re.compile(
    r'(?:youtu\.be/|youtube\.com/(?:watch\?(?:\S*?&)?v=|embed/|shorts/|live/|v/))'
    r'([A-Za-z0-9_-]{11})'
)
VIDEO_ID = re.compile(r'^[A-Za-z0-9_-]{11}$')
DIGEST = re.compile(r'^[0-9a-f]{64}$')

log = logging.getLogger(__name__)


class PartyError(Exception):
    """Something the caller should be told in plain words."""


#* Callable Entry Points -----------------------------------------------------


def request_video(uid, secret):
    """Issues one video title and the digest of its id."""
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(days=WINDOW_DAYS)

    client = fb.db()
    video = _random_recent_video(cutoff)
    nonce = token_hex(16)
    attempt = {
        'at': now,
        'nonce': nonce,
        'digest': _digest(secret, uid, nonce, video['id']),
        'guesses': 0,
    }

    _issue(client.transaction(), fb.meta(uid, client), attempt, cutoff)

    log.info('Party challenge issued to %s', uid)
    return {
        'title': video['title'],
        'published': _iso(video['published']),
        'hash': attempt['digest'],
        'guesses': MAX_GUESSES,
    }


def approve(uid, url, submitted, secret):
    """Grants 90 days of membership when `url` is the video `submitted` was issued for."""
    video_id = _video_id(url)
    if video_id is None:
        raise PartyError('That is not a YouTube video URL')
    if not isinstance(submitted, str) or not DIGEST.match(submitted):
        raise PartyError('That approval request is no longer open, request a new video')

    now = datetime.now(timezone.utc)
    client = fb.db()

    problem = _settle(client.transaction(), fb.meta(uid, client), uid, video_id, submitted, secret, now)
    if problem:
        log.info('Party approval refused for %s: %s', uid, problem)
        raise PartyError(problem)

    log.info('Party membership approved for %s', uid)
    return {
        'approved': True,
        'party': _iso(now),
        'expiresAt': _iso(now + timedelta(days=MEMBERSHIP_DAYS)),
    }


#* Transactions --------------------------------------------------------------


@fb.transactional
def _issue(transaction, ref, attempt, cutoff):
    """Appends the challenge, keeping only the newest few so the doc stays small."""
    attempts = _in_window(fb.read(ref, transaction) or {}, cutoff)
    fb.merge(ref, {'partyAttempts': (attempts + [attempt])[-KEEP_ATTEMPTS:]}, transaction)


@fb.transactional
def _settle(transaction, ref, uid, video_id, submitted, secret, now):
    """None when the membership was granted, otherwise why it was not."""
    attempts = _in_window(fb.read(ref, transaction) or {}, now - timedelta(days=WINDOW_DAYS))

    attempt = _open_attempt(attempts, submitted)
    if attempt is None:
        return 'That approval request is no longer open, request a new video'

    if not hmac.compare_digest(_digest(secret, uid, attempt['nonce'], video_id), attempt['digest']):
        attempt['guesses'] = attempt.get('guesses', 0) + 1
        fb.merge(ref, {'partyAttempts': attempts}, transaction)
        left = MAX_GUESSES - attempt['guesses']
        if left <= 0:
            return 'That is not the right video. This request is now closed'
        return f'That is not the right video, {left} tries left'

    attempt['usedAt'] = now
    fb.merge(ref, {'partyAttempts': attempts, 'party': now}, transaction)
    return None


#* Private Methods -----------------------------------------------------------


def _digest(secret, uid, nonce, video_id):
    message = f'{uid}|{nonce}|{video_id}'.encode()
    return hmac.new(secret.encode(), message, sha256).hexdigest()


def _video_id(url):
    if not isinstance(url, str):
        return None
    url = url.strip()
    if VIDEO_ID.match(url):
        return url
    match = VIDEO_URL.search(url)
    return match.group(1) if match else None


def _in_window(data, cutoff):
    attempts = data.get('partyAttempts') or []
    return [item for item in attempts if (item.get('at') or EPOCH) >= cutoff]


def _open_attempt(attempts, submitted):
    for attempt in attempts:
        if attempt.get('usedAt') or attempt.get('guesses', 0) >= MAX_GUESSES:
            continue
        if not DIGEST.match(str(attempt.get('digest') or '')):
            continue
        if hmac.compare_digest(attempt['digest'], submitted):
            return attempt
    return None


def _random_recent_video(cutoff):
    blocks = fb.video_blocks(PARTY_CID).where(filter=fb.FieldFilter('newest', '>=', cutoff)).stream()
    recent = [
        {'id': vid, 'title': fields.get('title') or 'Untitled', 'published': fields.get('published')}
        for block in blocks
        for vid, fields in ((block.to_dict() or {}).get('videos') or {}).items()
        if (fields.get('published') or EPOCH) >= cutoff
    ]
    if not recent:
        raise PartyError(f'No TLDR Party video has been published in the last {WINDOW_DAYS} days')
    return choice(recent)


def _iso(moment):
    return moment.isoformat() if moment else None
