"""Firestore repository for the `channels/{cid}/videos` block subcollection.

A block's document id is its start boundary, formatted `20240104T080000Z`. A video
belongs to the block with the greatest `startAt` less than or equal to its
`published` date. Ids are boundaries, not descriptions, so a video landing in the
middle of history never renumbers anything.
"""

import logging
from datetime import datetime, timezone

from google.cloud import firestore

BLOCK_TARGET = 200
BLOCK_WARN = 350
BATCH_BLOCKS = 10

META_FIELDS = ['startAt', 'oldest', 'newest', 'count', 'videoIds']

log = logging.getLogger(__name__)


def block_id(moment):
    return moment.astimezone(timezone.utc).strftime('%Y%m%dT%H%M%SZ')


#* Reads ---------------------------------------------------------------------


def load_meta(db, cid):
    """Every block's metadata, oldest first. Never pulls the `videos` maps."""
    query = _blocks(db, cid).select(META_FIELDS).order_by('startAt')
    return [_meta_from_doc(doc) for doc in query.stream()]


def known_video_ids(meta):
    return {vid for block in meta for vid in block['videoIds']}


#* Writes --------------------------------------------------------------------


def insert(db, cid, videos):
    """Route videos into blocks and write only the blocks that changed."""
    dated = _oldest_first(videos)
    if not dated:
        return 0

    meta = load_meta(db, cid)
    existing = known_video_ids(meta)
    staged = {}

    for video in dated:
        if video['id'] in existing:
            continue
        existing.add(video['id'])
        target = _route(meta, staged, video)
        staged.setdefault(target, []).append(video)

    if not staged:
        return 0

    for start_id, additions in staged.items():
        _merge_block(db, cid, start_id, additions)

    _refresh_channel(db, cid)
    return len(staged)


def rebuild(db, cid, videos):
    """Wipe the subcollection and re-chunk every video from the oldest end."""
    _delete_all(db, cid)

    dated = _oldest_first(videos)
    chunks = [dated[i:i + BLOCK_TARGET] for i in range(0, len(dated), BLOCK_TARGET)]

    batch = db.batch()
    for position, chunk in enumerate(chunks, start=1):
        start = chunk[0]['published']
        batch.set(_blocks(db, cid).document(block_id(start)), _build_block(start, chunk))
        if position % BATCH_BLOCKS == 0:
            batch.commit()
            batch = db.batch()
    batch.commit()

    _refresh_channel(db, cid, clear_legacy=True)
    return len(chunks)


#* Private Methods -----------------------------------------------------------


def _route(meta, staged, video):
    """The block id this video belongs in, creating a boundary when it falls outside."""
    published = video['published']
    if not meta:
        start_id = block_id(published)
        meta.append({'startAt': published, 'id': start_id, 'count': 0, 'videoIds': []})
        return start_id

    if published < meta[0]['startAt']:
        start_id = block_id(published)
        meta.insert(0, {'startAt': published, 'id': start_id, 'count': 0, 'videoIds': []})
        return start_id

    covering = meta[0]
    for block in meta:
        if block['startAt'] <= published:
            covering = block
        else:
            break

    is_newest = covering is meta[-1]
    pending = len(staged.get(covering['id'], []))
    if is_newest and covering['count'] + pending >= BLOCK_TARGET:
        start_id = block_id(published)
        if start_id != covering['id']:
            meta.append({'startAt': published, 'id': start_id, 'count': 0, 'videoIds': []})
            return start_id

    return covering['id']


def _merge_block(db, cid, start_id, additions):
    ref = _blocks(db, cid).document(start_id)
    snapshot = ref.get()
    current = snapshot.to_dict() if snapshot.exists else {}

    videos = current.get('videos') or {}
    for video in additions:
        videos[video['id']] = _video_fields(video)

    start = current.get('startAt') or additions[0]['published']
    ref.set(_build_block(start, None, videos=videos))

    if len(videos) > BLOCK_WARN:
        log.warning('%s/%s holds %d videos, past the %d soft ceiling',
                    cid, start_id, len(videos), BLOCK_WARN)


def _build_block(start, chunk, videos=None):
    if videos is None:
        videos = {video['id']: _video_fields(video) for video in chunk}

    published = [v['published'] for v in videos.values() if v['published'] is not None]
    return {
        'startAt': start,
        'oldest': min(published) if published else start,
        'newest': max(published) if published else start,
        'count': len(videos),
        'videoIds': sorted(videos.keys()),
        'videos': videos,
    }


def _video_fields(video):
    return {
        'title': video.get('title') or 'Untitled',
        'published': video.get('published'),
        'description': video.get('description'),
        'imageUrl': video.get('imageUrl'),
    }


def _refresh_channel(db, cid, clear_legacy=False):
    meta = load_meta(db, cid)
    updates = {
        'videoCount': sum(block['count'] for block in meta),
        'blockCount': len(meta),
        'lastSyncedAt': datetime.now(timezone.utc),
    }
    if clear_legacy:
        updates['videos'] = firestore.DELETE_FIELD
    db.collection('channels').document(cid).set(updates, merge=True)


def _delete_all(db, cid):
    batch = db.batch()
    for position, doc in enumerate(_blocks(db, cid).list_documents(), start=1):
        batch.delete(doc)
        if position % 200 == 0:
            batch.commit()
            batch = db.batch()
    batch.commit()


def _blocks(db, cid):
    return db.collection('channels').document(cid).collection('videos')


def _meta_from_doc(doc):
    data = doc.to_dict() or {}
    return {
        'id': doc.id,
        'startAt': data.get('startAt'),
        'oldest': data.get('oldest'),
        'newest': data.get('newest'),
        'count': data.get('count') or 0,
        'videoIds': data.get('videoIds') or [],
    }


def _oldest_first(videos):
    dated = [v for v in videos if v.get('published') is not None]
    if len(dated) != len(videos):
        log.warning('Skipped %d undated videos, which have no date block to live in',
                    len(videos) - len(dated))
    return sorted(dated, key=lambda v: v['published'])
