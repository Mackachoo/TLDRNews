"""Orchestration: fetch from YouTube, diff against what is stored, write blocks."""

import logging

from ..utils import firebase_client as fb
from . import block_store
from .youtube_client import YouTubeClient, YouTubeError

log = logging.getLogger(__name__)


class ChannelNotFound(Exception):
    pass


def sync(cid, api_key, rebuild=False):
    """Ingest a channel's videos and series. Returns a summary of what changed."""
    db = fb.db()
    channel = _channel_data(db, cid)

    client = YouTubeClient(api_key)
    stop_at = None if rebuild else _watermark(db, cid)

    content = client.fetch_channel_content(
        channel['channelUrl'],
        exclude_ids=() if rebuild else block_store.known_video_ids(block_store.load_meta(db, cid)),
        stop_at=stop_at,
    )
    videos = content['videos']
    series = content['series']
    source = content['channel']

    if rebuild:
        blocks_written = block_store.rebuild(db, cid, videos)
    else:
        blocks_written = block_store.insert(db, cid, videos)

    _write_series(db, cid, series)
    _record_source(db, cid, source)

    summary = {
        'addedVideos': len(videos),
        'addedSeries': len(series),
        'blocksWritten': blocks_written,
        'quotaUnits': client.quota_used,
        'sourceChannel': source['title'],
        'sourceChannelId': source['id'],
    }
    log.info('Synced %s from %r (%s): %s', cid, source['title'], source['id'], summary)
    return summary


def resolve_video(url, api_key):
    return _json_safe(YouTubeClient(api_key).video_url_to_video(url))


def resolve_series(url, api_key):
    return _json_safe(YouTubeClient(api_key).playlist_url_to_series(url))


def channel_ids():
    return fb.channel_ids()


#* Private Methods -----------------------------------------------------------


def _json_safe(item):
    """Callable responses are JSON, so dates go out as ISO strings."""
    published = item.get('published')
    return {**item, 'published': published.isoformat() if published else None}


def _channel_data(db, cid):
    data = fb.read(fb.channel(cid, db))
    if data is None:
        raise ChannelNotFound(f'Channel "{cid}" does not exist')

    if not data.get('channelUrl'):
        raise ChannelNotFound(f'Channel "{cid}" has no channelUrl set')
    return data


def _watermark(db, cid):
    meta = block_store.load_meta(db, cid)
    return meta[-1]['newest'] if meta else None


def _record_source(db, cid, source):
    """Stores which YouTube channel the URL actually resolved to, so a channel
    pointed at the wrong URL is visible in the data instead of silently wrong."""
    previous = fb.read(fb.channel(cid, db)) or {}
    if previous.get('youtubeChannelId') not in (None, source['id']):
        log.warning(
            '%s now resolves to %r (%s), previously %s — check its channelUrl',
            cid, source['title'], source['id'], previous['youtubeChannelId'],
        )

    fb.merge(
        fb.channel(cid, db),
        {'youtubeChannelId': source['id'], 'youtubeChannelTitle': source['title']},
    )


def _write_series(db, cid, series):
    if not series:
        return
    entries = {
        item['id']: {
            'title': item['title'],
            'published': item['published'],
            'description': item['description'],
            'imageUrl': item['imageUrl'],
        }
        for item in series
    }
    fb.merge(fb.channel(cid, db), {'series': entries})
