"""Block reads and writes against a real Firestore, including the queries the
Flutter client runs to page through blocks.

Start the emulator first, then point the tests at it:

    firebase emulators:start --only firestore
    FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 functions/venv/bin/python -m pytest functions/tests
"""

import os
from datetime import datetime, timedelta, timezone

import pytest

from src.youtube import block_store as bs

pytestmark = pytest.mark.skipif(
    not os.environ.get('FIRESTORE_EMULATOR_HOST'),
    reason='FIRESTORE_EMULATOR_HOST is not set',
)

BASE = datetime(2020, 1, 1, tzinfo=timezone.utc)
PROJECT = 'tldr-news-229ac'
CID = 'test-channel'


def video(n, day):
    return {
        'id': f'v{n}',
        'title': f'Video {n}',
        'published': BASE + timedelta(days=day),
        'description': None,
        'imageUrl': None,
    }


@pytest.fixture(scope='module')
def db():
    import firebase_admin
    from firebase_admin import firestore

    if not firebase_admin._apps:
        firebase_admin.initialize_app(options={'projectId': PROJECT})
    return firestore.client()


@pytest.fixture
def seeded(db):
    db.collection('channels').document(CID).set(
        {'name': 'Test', 'channelUrl': 'x', 'videos': {'legacy': {'title': 'inline'}}}
    )
    bs.rebuild(db, CID, [video(i, i) for i in range(1000)])
    return db


def blocks(db):
    return db.collection('channels').document(CID).collection('videos')


def newest(db):
    from firebase_admin import firestore

    docs = blocks(db).order_by('startAt', direction=firestore.Query.DESCENDING).limit(1).get()
    return docs[0] if docs else None


def older_than(db, start_at):
    from firebase_admin import firestore

    docs = (
        blocks(db)
        .where(filter=firestore.FieldFilter('startAt', '<', start_at))
        .order_by('startAt', direction=firestore.Query.DESCENDING)
        .limit(1)
        .get()
    )
    return docs[0] if docs else None


#* Rebuild -------------------------------------------------------------------


def test_rebuild_chunks_and_clears_the_legacy_inline_map(seeded):
    meta = bs.load_meta(seeded, CID)
    channel = seeded.collection('channels').document(CID).get().to_dict()

    assert len(meta) == 1000 // bs.BLOCK_TARGET
    assert sum(block['count'] for block in meta) == 1000
    assert channel['videoCount'] == 1000
    assert channel['blockCount'] == 5
    assert 'videos' not in channel


#* Client queries ------------------------------------------------------------


def test_paging_walks_every_block_newest_to_oldest_without_repeats(seeded):
    expected = [block['id'] for block in bs.load_meta(seeded, CID)][::-1]

    walked, doc = [], newest(seeded)
    while doc is not None:
        walked.append(doc.id)
        doc = older_than(seeded, doc.to_dict()['startAt'])

    assert walked == expected


def test_a_date_resolves_to_the_block_whose_range_covers_it(seeded):
    from firebase_admin import firestore

    target = BASE + timedelta(days=450)
    found = (
        blocks(seeded)
        .where(filter=firestore.FieldFilter('startAt', '<=', target))
        .order_by('startAt', direction=firestore.Query.DESCENDING)
        .limit(1)
        .get()[0]
        .to_dict()
    )

    assert found['startAt'] <= target <= found['newest']


#* Incremental writes --------------------------------------------------------


def test_appending_newer_videos_leaves_existing_block_ids_alone(seeded):
    before = [block['id'] for block in bs.load_meta(seeded, CID)]

    bs.insert(seeded, CID, [video(5000 + i, 1000 + i) for i in range(10)])

    after = bs.load_meta(seeded, CID)
    assert sum(block['count'] for block in after) == 1010
    assert [block['id'] for block in after][: len(before)] == before


def test_mid_history_insert_overfills_one_block_and_renumbers_nothing(seeded):
    before = [block['id'] for block in bs.load_meta(seeded, CID)]

    bs.insert(seeded, CID, [video(9999, 450)])

    after = bs.load_meta(seeded, CID)
    overfull = [block for block in after if block['count'] > bs.BLOCK_TARGET]
    assert [block['id'] for block in after] == before
    assert len(overfull) == 1
    assert overfull[0]['count'] == bs.BLOCK_TARGET + 1


def test_known_videos_are_not_rewritten(seeded):
    assert bs.insert(seeded, CID, [video(1, 1), video(2, 2)]) == 0


def test_no_video_is_lost_or_duplicated(seeded):
    bs.insert(seeded, CID, [video(7000 + i, 1000 + i) for i in range(50)])

    stored = [vid for block in bs.load_meta(seeded, CID) for vid in block['videoIds']]
    assert len(stored) == len(set(stored)) == 1050
