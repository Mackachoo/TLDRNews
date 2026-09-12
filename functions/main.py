"""Cloud Functions entry points. Implementation lives under src/."""

from firebase_admin import initialize_app
from firebase_functions import https_fn, options, params, scheduler_fn

from src.utils.admin_guard import require_admin
from src.youtube import channel_sync
from src.youtube.youtube_client import YouTubeError

options.set_global_options(max_instances=10, region='europe-west1')

YOUTUBE_API_KEY = params.SecretParam('YOUTUBE_API_KEY')

initialize_app()


#* Callables -----------------------------------------------------------------


@https_fn.on_call(secrets=[YOUTUBE_API_KEY], timeout_sec=540, memory=options.MemoryOption.MB_512)
def sync_channel(req: https_fn.CallableRequest) -> dict:
    """Admin entry point for ingesting a channel or resolving a single URL."""
    require_admin(req)

    data = req.data or {}
    action = data.get('action') or 'sync'
    api_key = YOUTUBE_API_KEY.value

    try:
        if action == 'resolve_video':
            return channel_sync.resolve_video(_required(data, 'url'), api_key)
        if action == 'resolve_series':
            return channel_sync.resolve_series(_required(data, 'url'), api_key)
        if action == 'sync':
            return channel_sync.sync(
                _required(data, 'cid'), api_key, rebuild=data.get('mode') == 'rebuild'
            )
    except channel_sync.ChannelNotFound as error:
        raise https_fn.HttpsError(https_fn.FunctionsErrorCode.NOT_FOUND, str(error))
    except YouTubeError as error:
        raise https_fn.HttpsError(https_fn.FunctionsErrorCode.UNAVAILABLE, str(error))

    raise https_fn.HttpsError(
        https_fn.FunctionsErrorCode.INVALID_ARGUMENT, f'Unknown action "{action}"'
    )


#* Schedules -----------------------------------------------------------------


@scheduler_fn.on_schedule(
    schedule='every day 03:00',
    secrets=[YOUTUBE_API_KEY],
    timeout_sec=540,
    memory=options.MemoryOption.MB_512,
)
def sync_all_channels(event: scheduler_fn.ScheduledEvent) -> None:
    """Incremental sync of every channel. Never rebuilds."""
    api_key = YOUTUBE_API_KEY.value
    for cid in channel_sync.channel_ids():
        try:
            channel_sync.sync(cid, api_key)
        except (channel_sync.ChannelNotFound, YouTubeError) as error:
            print(f'sync_all_channels: skipping {cid}: {error}')


def _required(data, key):
    value = data.get(key)
    if not value:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.INVALID_ARGUMENT, f'Missing "{key}"'
        )
    return value
