"""Client for the YouTube Data API v3."""

from datetime import datetime, timezone

import requests

BASE_URL = 'https://www.googleapis.com/youtube/v3'
TIMEOUT = 15
PAGE_SIZE = 50

DEFAULT_QUOTA_BUDGET = 5000


class YouTubeError(Exception):
    pass


class QuotaExhausted(YouTubeError):
    pass


class YouTubeClient:
    def __init__(self, api_key, quota_budget=DEFAULT_QUOTA_BUDGET):
        self.api_key = api_key
        self.quota_budget = quota_budget
        self.quota_used = 0

    #* Channel Content ---------------------------------------------------

    def fetch_channel_content(self, channel_url, exclude_ids=(), limit=None, stop_at=None):
        channel = self.resolve_channel(channel_url)

        videos = self.fetch_playlist_videos(
            channel['uploads'], exclude_ids=exclude_ids, limit=limit, stop_at=stop_at
        )
        series = self._fetch_channel_playlists(channel['id'])
        return {'videos': videos, 'series': series, 'channel': channel}

    def resolve_channel(self, channel_url):
        """Channel id, title and uploads playlist for a URL, in one exact lookup."""
        reference = _extract_channel_id(channel_url)
        if not reference:
            raise YouTubeError(
                f'Could not read a channel from "{channel_url}". Expected '
                'youtube.com/channel/UCxxxx, youtube.com/@handle, or a bare UC channel id.'
            )

        lookup = (
            {'forHandle': reference[1:]} if reference.startswith('@') else {'id': reference}
        )
        items = self._get('channels', part='snippet,contentDetails', **lookup).get('items') or []
        if not items:
            raise YouTubeError(f'No YouTube channel matches "{channel_url}"')

        item = items[0]
        uploads = ((item.get('contentDetails') or {}).get('relatedPlaylists') or {}).get('uploads')
        if not uploads:
            raise YouTubeError(f'Channel "{channel_url}" exposes no uploads playlist')

        return {
            'id': item['id'],
            'title': (item.get('snippet') or {}).get('title'),
            'uploads': uploads,
        }

    def fetch_playlist_videos(self, playlist_id, exclude_ids=(), limit=None, stop_at=None):
        """Newest first. `limit=None` pages the whole playlist; `stop_at` ends it early."""
        excluded = set(exclude_ids)
        videos = []
        page_token = None

        while limit is None or len(videos) < limit:
            data = self._get(
                'playlistItems',
                part='snippet',
                playlistId=playlist_id,
                maxResults=PAGE_SIZE,
                pageToken=page_token,
            )
            items = data.get('items') or []
            if not items:
                break

            for item in items:
                video = _video_from_snippet(item.get('snippet') or {})
                if video is None:
                    continue
                if stop_at is not None and video['published'] is not None:
                    if video['published'] <= stop_at:
                        return _newest_first(videos)
                if video['id'] not in excluded:
                    videos.append(video)

            page_token = data.get('nextPageToken')
            if not page_token:
                break

        ordered = _newest_first(videos)
        return ordered[:limit] if limit else ordered

    #* Single Items --------------------------------------------------------

    def video_url_to_video(self, video_url):
        video_id = _extract_video_id(video_url)
        if not video_id:
            raise YouTubeError('Invalid YouTube video URL format')

        items = self._get('videos', part='snippet', id=video_id).get('items') or []
        if not items:
            raise YouTubeError(f'Video "{video_id}" not found')

        snippet = items[0].get('snippet') or {}
        return {
            'id': video_id,
            'title': snippet.get('title') or 'Untitled',
            'published': _parse_date(snippet.get('publishedAt')),
            'description': snippet.get('description'),
            'imageUrl': _thumbnail(snippet),
        }

    def playlist_url_to_series(self, playlist_url):
        playlist_id = _extract_playlist_id(playlist_url)
        if not playlist_id:
            raise YouTubeError('Invalid YouTube playlist URL format')

        items = self._get('playlists', part='snippet', id=playlist_id).get('items') or []
        if not items:
            raise YouTubeError(f'Playlist "{playlist_id}" not found')

        return _series_from_snippet(playlist_id, items[0].get('snippet') or {})

    #* Private Methods -----------------------------------------------------

    def _fetch_channel_playlists(self, channel_id, limit=PAGE_SIZE):
        series = []
        page_token = None

        while len(series) < limit:
            data = self._get(
                'playlists',
                part='snippet',
                channelId=channel_id,
                maxResults=PAGE_SIZE,
                pageToken=page_token,
            )
            for item in data.get('items') or []:
                if len(series) >= limit:
                    break
                playlist_id = item.get('id')
                if playlist_id:
                    series.append(_series_from_snippet(playlist_id, item.get('snippet') or {}))

            page_token = data.get('nextPageToken')
            if not page_token:
                break

        return series

    def _get(self, path, cost=1, **params):
        if self.quota_used + cost > self.quota_budget:
            raise QuotaExhausted(
                f'YouTube quota budget of {self.quota_budget} units reached at {path}'
            )
        self.quota_used += cost

        params = {k: v for k, v in params.items() if v is not None}
        params['key'] = self.api_key
        response = requests.get(f'{BASE_URL}/{path}', params=params, timeout=TIMEOUT)

        if response.status_code != 200:
            raise YouTubeError(f'{path} failed: {response.status_code} {response.text[:500]}')
        return response.json()


#* Parsing -----------------------------------------------------------------


def _video_from_snippet(snippet):
    video_id = (snippet.get('resourceId') or {}).get('videoId')
    if not video_id:
        return None
    return {
        'id': video_id,
        'title': snippet.get('title') or 'Untitled',
        'published': _parse_date(snippet.get('publishedAt')),
        'description': snippet.get('description'),
        'imageUrl': _thumbnail(snippet),
    }


def _series_from_snippet(playlist_id, snippet):
    return {
        'id': playlist_id,
        'title': snippet.get('title') or 'Untitled Playlist',
        'published': _parse_date(snippet.get('publishedAt')),
        'description': snippet.get('description'),
        'imageUrl': _thumbnail(snippet),
    }


def _thumbnail(snippet):
    return ((snippet.get('thumbnails') or {}).get('high') or {}).get('url')


def _parse_date(value):
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace('Z', '+00:00'))
    except (ValueError, AttributeError):
        return None


def _newest_first(videos):
    undated = datetime.min.replace(tzinfo=timezone.utc)
    return sorted(videos, key=lambda v: v['published'] or undated, reverse=True)


def _extract_channel_id(url):
    if url.startswith('UC') and len(url) == 24:
        return url
    if '/channel/' in url:
        return url.split('/channel/')[-1].split('/')[0].split('?')[0]
    if '/@' in url:
        handle = url.split('/@')[-1].split('/')[0].split('?')[0]
        return f'@{handle}' if handle else ''
    return ''


def _extract_video_id(url):
    if len(url) == 11 and '/' not in url and '?' not in url:
        return url
    if 'watch?v=' in url:
        return url.split('watch?v=')[-1].split('&')[0]
    if 'youtu.be' in url:
        return url.split('youtu.be/')[-1].split('?')[0]
    return ''


def _extract_playlist_id(url):
    if url.startswith('PL') and len(url) > 10:
        return url
    if 'list=' in url:
        return url.split('list=')[-1].split('&')[0]
    return ''
