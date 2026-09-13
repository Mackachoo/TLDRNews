"""The full request/approve round trip against a real Firestore.

Start the emulator first, then point the tests at it:

    firebase emulators:start --only firestore
    FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 functions/venv/bin/python -m pytest functions/tests
"""

import os
from datetime import datetime, timedelta, timezone
from uuid import uuid4

import pytest

from src.party import approval as pa
from src.utils import firebase_client as fb
from src.youtube import block_store as bs

pytestmark = pytest.mark.skipif(
    not os.environ.get('FIRESTORE_EMULATOR_HOST'),
    reason='FIRESTORE_EMULATOR_HOST is not set',
)

PROJECT = 'tldr-news-229ac'
SECRET = 'test-secret'

IDS = ['aaaaaaaaaaa', 'bbbbbbbbbbb', 'ccccccccccc', 'ddddddddddd']


def video(n, days_ago):
    return {
        'id': IDS[n],
        'title': f'Party Video {n}',
        'published': datetime.now(timezone.utc) - timedelta(days=days_ago),
        'description': None,
        'imageUrl': f'https://i.ytimg.com/vi/{IDS[n]}/hq.jpg',
    }


@pytest.fixture(scope='module', autouse=True)
def party_channel():
    import firebase_admin

    if not firebase_admin._apps:
        firebase_admin.initialize_app(options={'projectId': PROJECT})

    db = fb.db()
    fb.merge(fb.channel(pa.PARTY_CID, db), {'name': 'TLDR Party', 'channelUrl': 'x'})
    bs.rebuild(db, pa.PARTY_CID, [video(0, 1), video(1, 3), video(2, 6)])
    return db


@pytest.fixture
def uid():
    return f'test-{uuid4().hex}'


def attempts(uid):
    return (fb.read(fb.meta(uid)) or {}).get('partyAttempts') or []


def url_for(title):
    return f'https://www.youtube.com/watch?v={IDS[int(title.rsplit(" ", 1)[1])]}'


#* Requesting ----------------------------------------------------------------


def test_a_request_issues_a_title_and_a_hash_but_never_the_video_id(uid):
    issued = pa.request_video(uid, SECRET)

    assert issued['title'].startswith('Party Video')
    assert len(issued['hash']) == 64
    assert not any(vid in str(issued) for vid in IDS)


def test_the_stored_attempt_holds_no_answer_for_a_reader_of_meta(uid):
    pa.request_video(uid, SECRET)

    stored = str(attempts(uid))
    assert not any(vid in stored for vid in IDS)


def test_only_videos_inside_the_window_are_ever_picked(uid):
    titles = set()
    for _ in range(12):
        picked = pa.request_video(f'{uid}-{uuid4().hex}', SECRET)
        titles.add(picked['title'])

    assert titles <= {'Party Video 0', 'Party Video 1', 'Party Video 2'}


def test_requests_are_never_refused_and_stored_attempts_stay_bounded(uid):
    issued = [pa.request_video(uid, SECRET) for _ in range(pa.KEEP_ATTEMPTS + 5)]

    assert all(item['hash'] for item in issued)
    assert len(attempts(uid)) == pa.KEEP_ATTEMPTS


def test_a_challenge_pushed_out_of_the_stored_window_stops_working(uid):
    first = pa.request_video(uid, SECRET)
    for _ in range(pa.KEEP_ATTEMPTS):
        pa.request_video(uid, SECRET)

    with pytest.raises(pa.PartyError):
        pa.approve(uid, url_for(first['title']), first['hash'], SECRET)


def test_the_newest_challenge_still_works_after_many_requests(uid):
    for _ in range(pa.KEEP_ATTEMPTS + 3):
        issued = pa.request_video(uid, SECRET)

    assert pa.approve(uid, url_for(issued['title']), issued['hash'], SECRET)['approved'] is True


#* Approving -----------------------------------------------------------------


def test_the_right_url_grants_membership_and_spends_the_attempt(uid):
    issued = pa.request_video(uid, SECRET)

    result = pa.approve(uid, url_for(issued['title']), issued['hash'], SECRET)

    assert result['approved'] is True
    assert fb.read(fb.meta(uid))['party'] is not None
    assert attempts(uid)[0]['usedAt'] is not None


def test_a_correct_pair_cannot_be_replayed(uid):
    issued = pa.request_video(uid, SECRET)
    pa.approve(uid, url_for(issued['title']), issued['hash'], SECRET)

    with pytest.raises(pa.PartyError):
        pa.approve(uid, url_for(issued['title']), issued['hash'], SECRET)


def test_a_wrong_url_burns_a_guess_and_closes_the_attempt(uid):
    issued = pa.request_video(uid, SECRET)
    wrong = f'https://www.youtube.com/watch?v={IDS[3]}'

    for expected in range(1, pa.MAX_GUESSES + 1):
        with pytest.raises(pa.PartyError):
            pa.approve(uid, wrong, issued['hash'], SECRET)
        assert attempts(uid)[0]['guesses'] == expected

    with pytest.raises(pa.PartyError):
        pa.approve(uid, url_for(issued['title']), issued['hash'], SECRET)
    assert 'party' not in (fb.read(fb.meta(uid)) or {})


def test_a_hash_issued_to_another_account_is_worthless(uid):
    issued = pa.request_video(uid, SECRET)
    other = f'test-{uuid4().hex}'

    with pytest.raises(pa.PartyError):
        pa.approve(other, url_for(issued['title']), issued['hash'], SECRET)

    assert 'party' not in (fb.read(fb.meta(other)) or {})


def test_approving_without_ever_requesting_fails(uid):
    with pytest.raises(pa.PartyError):
        pa.approve(uid, f'https://www.youtube.com/watch?v={IDS[0]}', 'f' * 64, SECRET)


def test_a_url_that_is_not_a_youtube_video_is_rejected(uid):
    issued = pa.request_video(uid, SECRET)

    with pytest.raises(pa.PartyError):
        pa.approve(uid, 'https://example.com/nope', issued['hash'], SECRET)
