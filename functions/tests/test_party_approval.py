"""The security-carrying parts of Party approval: what a digest is bound to,
which URLs normalise to the same answer, and which attempts stay open.

Run with: functions/venv/bin/python -m pytest functions/tests
"""

from datetime import datetime, timedelta, timezone

from src.party import approval as pa

NOW = datetime(2026, 9, 13, tzinfo=timezone.utc)
SECRET = 'test-secret'
UID = 'user-a'
NONCE = 'abc123'
VID = 'dQw4w9WgXcQ'


def attempt(digest, at=NOW, guesses=0, used=None):
    return {'at': at, 'nonce': NONCE, 'digest': digest, 'guesses': guesses, 'usedAt': used}


#* URL normalisation ---------------------------------------------------------


def test_every_youtube_url_shape_resolves_to_the_same_id():
    urls = [
        f'https://www.youtube.com/watch?v={VID}',
        f'https://youtube.com/watch?v={VID}&t=30s',
        f'https://m.youtube.com/watch?app=desktop&v={VID}',
        f'https://youtu.be/{VID}?si=xyz',
        f'https://www.youtube.com/shorts/{VID}',
        f'https://www.youtube.com/embed/{VID}',
        f'  https://www.youtube.com/live/{VID}  ',
        VID,
    ]

    assert {pa._video_id(url) for url in urls} == {VID}


def test_non_video_urls_are_rejected():
    for url in ['https://youtube.com/@tldrnews', 'not a url', '', None, 12, f'{VID}x']:
        assert pa._video_id(url) is None


#* Digest binding ------------------------------------------------------------


def test_the_same_video_reached_by_different_urls_digests_identically():
    short = pa._digest(SECRET, UID, NONCE, pa._video_id(f'https://youtu.be/{VID}'))
    long = pa._digest(SECRET, UID, NONCE, pa._video_id(f'https://www.youtube.com/watch?v={VID}&t=9'))

    assert short == long


def test_a_digest_is_bound_to_the_uid_the_nonce_and_the_secret():
    base = pa._digest(SECRET, UID, NONCE, VID)

    assert pa._digest(SECRET, 'user-b', NONCE, VID) != base
    assert pa._digest(SECRET, UID, 'other-nonce', VID) != base
    assert pa._digest('other-secret', UID, NONCE, VID) != base
    assert pa._digest(SECRET, UID, NONCE, 'jNQXAC9IVRw') != base


#* Attempt window ------------------------------------------------------------


def test_attempts_older_than_the_window_stop_counting():
    cutoff = NOW - timedelta(days=pa.WINDOW_DAYS)
    data = {'partyAttempts': [
        attempt('a', at=NOW - timedelta(days=15)),
        attempt('b', at=NOW - timedelta(days=13)),
        attempt('c', at=NOW),
    ]}

    assert [item['digest'] for item in pa._in_window(data, cutoff)] == ['b', 'c']


def test_a_missing_meta_doc_counts_as_no_attempts():
    assert pa._in_window({}, NOW) == []


#* Open attempts -------------------------------------------------------------


def test_a_digest_that_was_never_issued_matches_nothing():
    assert pa._open_attempt([attempt('a' * 64)], 'b' * 64) is None


def test_a_spent_attempt_cannot_be_replayed():
    digest = 'a' * 64

    assert pa._open_attempt([attempt(digest, used=NOW)], digest) is None


def test_an_attempt_closes_once_the_guesses_run_out():
    digest = 'a' * 64

    assert pa._open_attempt([attempt(digest, guesses=pa.MAX_GUESSES - 1)], digest) is not None
    assert pa._open_attempt([attempt(digest, guesses=pa.MAX_GUESSES)], digest) is None


def test_the_matching_open_attempt_is_returned():
    digest = 'a' * 64
    open_one = attempt(digest)

    assert pa._open_attempt([attempt('b' * 64), open_one], digest) is open_one
