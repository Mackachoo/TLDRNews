"""Block routing rules. Pure logic, no Firestore needed.

Run with: functions/venv/bin/python -m pytest functions/tests
"""

from datetime import datetime, timedelta, timezone

from src.youtube import block_store as bs

BASE = datetime(2020, 1, 1, tzinfo=timezone.utc)


def video(n, day):
    return {
        'id': f'v{n}',
        'title': f'Video {n}',
        'published': BASE + timedelta(days=day),
        'description': None,
        'imageUrl': None,
    }


def route_all(videos, meta=None):
    meta = [] if meta is None else meta
    staged = {}
    for item in bs._oldest_first(videos):
        staged.setdefault(bs._route(meta, staged, item), []).append(item)
    return staged, meta


def block(start, count, newest=None):
    return {
        'id': bs.block_id(start),
        'startAt': start,
        'newest': newest or start,
        'count': count,
        'videoIds': [],
    }


#* Chunking ------------------------------------------------------------------


def test_in_order_videos_chunk_into_target_sized_blocks():
    staged, _ = route_all([video(i, i) for i in range(1000)])

    assert len(staged) == 1000 // bs.BLOCK_TARGET
    assert [len(v) for v in staged.values()] == [bs.BLOCK_TARGET] * 5


def test_boundary_ids_sort_chronologically():
    staged, _ = route_all([video(i, i) for i in range(1000)])

    assert list(staged.keys()) == sorted(staged.keys())


#* Appending -----------------------------------------------------------------


def test_newer_videos_join_an_unfilled_newest_block():
    store = [block(BASE, count=100)]

    staged, _ = route_all([video(i, 400 + i) for i in range(10)], meta=store)

    assert list(staged.keys()) == [bs.block_id(BASE)]


def test_full_newest_block_overflows_into_one_new_block():
    store = [block(BASE, count=bs.BLOCK_TARGET)]

    staged, meta = route_all([video(i, 400 + i) for i in range(10)], meta=store)

    assert len(staged) == 1
    assert list(staged.keys()) != [bs.block_id(BASE)]
    assert len(meta) == 2


#* Out-of-order inserts ------------------------------------------------------


def test_mid_history_video_joins_its_covering_block_without_renumbering():
    older, newer = BASE, BASE + timedelta(days=200)
    store = [block(older, bs.BLOCK_TARGET, newest=newer), block(newer, 150)]
    ids_before = [b['id'] for b in store]

    staged, meta = route_all([video(99, 100)], meta=store)

    assert list(staged.keys()) == [bs.block_id(older)]
    assert [b['id'] for b in meta] == ids_before


def test_video_older_than_all_history_opens_a_new_first_block():
    store = [block(BASE, 10)]

    _, meta = route_all([video(99, -50)], meta=store)

    assert meta[0]['startAt'] == BASE - timedelta(days=50)
    assert len(meta) == 2


def test_undated_videos_are_skipped():
    undated = dict(video(1, 0), published=None)

    assert bs._oldest_first([undated, video(2, 1)]) == [video(2, 1)]


#* Block contents ------------------------------------------------------------


def test_block_records_its_own_date_bounds():
    built = bs._build_block(BASE, [video(1, 0), video(2, 5), video(3, 2)])

    assert built['count'] == 3
    assert built['videoIds'] == ['v1', 'v2', 'v3']
    assert built['oldest'] == BASE
    assert built['newest'] == BASE + timedelta(days=5)
    assert built['videos']['v2']['published'] == BASE + timedelta(days=5)
