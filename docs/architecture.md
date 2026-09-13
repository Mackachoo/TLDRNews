# Architecture

A short guided tour of how the app is wired together.

## Layers

```
┌──────────────────────────────────────────────────────────┐
│ Screens         (lib/src/screens)                        │
│   • Stateless widgets bound to a Controller via          │
│     ListenableBuilder                                    │
├──────────────────────────────────────────────────────────┤
│ Controllers     (per-screen *_controller.dart + AppCtlr) │
│   • ChangeNotifier subclasses                            │
│   • Hold view state, expose intent methods               │
├──────────────────────────────────────────────────────────┤
│ Services        (lib/src/services)                       │
│   • Firestore, Auth, YouTube, RemoteConfig, Local prefs  │
│   • Stateless — pure I/O                                 │
├──────────────────────────────────────────────────────────┤
│ Objects         (lib/src/objects)                        │
│   • Plain data models with json_serializable             │
└──────────────────────────────────────────────────────────┘
```

State management is intentionally low-tech: `ChangeNotifier` + `ListenableBuilder`. No Riverpod / BLoC / Provider. The trade-off is fewer dependencies and a shallower learning curve, at the cost of some manual `notifyListeners()` discipline.

## Top-level controller — `AppCtlr`

[lib/src/app_controller.dart](../lib/src/app_controller.dart) is a singleton that owns:

- `auth` — `AuthController` (current user, sign-in / sign-up methods, admin meta).
- `settings` — `SettingsController` (theme, persisted via `shared_preferences`).
- `channels` — a `Map<String, ChannelController>` lazily populated when a channel screen is first opened.

`MaterialApp.router` rebuilds whenever `auth` or `settings` notify, via `Listenable.merge([...])` in [app.dart:27](../lib/src/app.dart#L27).

## Routing

`go_router` configuration is in [app.dart:41-104](../lib/src/app.dart#L41-L104). A single `ShellRoute` wraps the app chrome (bottom nav, etc.) and contains:

| Path                | Screen                       | Notes                            |
| ------------------- | ---------------------------- | -------------------------------- |
| `/`                 | `HomeScreen`                 | List of channels                 |
| `/settings`         | `SettingsScreen`             | Theme, account                   |
| `/account`          | `AuthScreen`                 | Sign-in / register               |
| `/channel/:id`      | `ChannelScreen`              | Public channel view              |
| `/admin`            | `AdminScreen`                | Admin home (gated)               |
| `/admin/users`      | `AdminUsersScreen`           | Manage admin flags               |
| `/admin/channel/:id`| `AdminChannelScreen`         | Edit channel + YouTube ingest    |
| `/channel/:cid/video/:id` | `VideoScreen`          | Full-screen player (outside shell)|

A `redirect` callback rejects `/admin/**` for non-admin users.

## Data model

Stored in Cloud Firestore (`eur3`). All dates are `Timestamp`s.

```text
accounts/{uid}    — user profile, preferences (per-user, owner-only RW)
meta/{uid}        — { admin: bool, party: Timestamp, partyAttempts: [...] }
                    (readable by any auth'd user, writable only by functions and admins)
channels/{cid}    — channel doc (public read, function-only write)
  ├─ name, channelUrl, description
  ├─ series: { playlistId → Series }
  ├─ videoCount, blockCount, lastSyncedAt
  └─ videos/{blockId}    — subcollection of video blocks
       ├─ startAt, oldest, newest
       ├─ count, videoIds
       └─ videos: { videoId → YoutubeVideo }
```

### Video blocks

A channel's videos are split across `channels/{cid}/videos`, roughly 200 per
document, so neither the channel doc nor a single read grows without bound.

A block's document id is its **start boundary**, a UTC instant written
`20240104T080000Z`. A video belongs to the block with the greatest `startAt` at
or before its published date. Because the id is a boundary rather than a
description of contents, a video inserted into the middle of history joins the
block already covering its date — that block simply grows past 200 — and no
document is ever renumbered. Blocks are capped in practice by Firestore's 1 MiB
limit, around 400 videos; `rebuild` re-chunks a channel if one gets close.

Every stored field other than `startAt` is derived from the `videos` map, so the
map is the only source of truth and Dart and Python compute the rest identically.

`startAt` is indexed automatically as a single field, so all paging is one query:

| Need | Query on `channels/{cid}/videos` |
| --- | --- |
| Newest block | `orderBy('startAt', desc).limit(1)` |
| Next older block | `where('startAt', <, current).orderBy('startAt', desc).limit(1)` |
| Block covering a date | `where('startAt', <=, date).orderBy('startAt', desc).limit(1)` |
| Block holding a video id, within its channel | `channels/{cid}/videos.where('videoIds', arrayContains: id).limit(1)` |

The video-id lookup needs the `videoIds` field override declared in
[firestore.indexes.json](../firebase/firestore.indexes.json). It is scoped to
one channel rather than a `collectionGroup` query across all of them — the URL
carries `cid`, so the query and the rule that gates it both stay bound to a
single, known channel; see [security.md](security.md#video-links) for why.

### Reading blocks in the app

`VideoPaging` ([video_paging.dart](../lib/src/screens/channels/video_paging.dart))
holds the loaded blocks and walks them newest first, one per request.
`ChannelController` and `AdminChannelController` both mix it in. `VideoGrid`
requests the next block as the scroll nears the end, and again after layout when
a block was too short to fill the screen.

A `/channel/:cid/video/:id` link for a video in a block nobody has paged in yet
falls back to the query above, so shared links resolve regardless of scroll depth.

Dart classes live in [lib/src/objects/](../lib/src/objects/) and use
`json_serializable`. Regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`Channel` extends `ChannelSnippet` so list views can render quickly with just
`{id, name}`.

## Services

- **`FirestoreService`** + per-collection modules in `services/firestore/` — typed reads/writes, with a short-lived in-memory cache in `FirestoreCore`.
- **`FunctionsService`** — callable Cloud Functions. All YouTube ingestion goes through here; the client holds no YouTube API key.
- **`AuthService`** — wraps `firebase_auth` and `google_sign_in`. Returns `UserCredential` and lets `AuthController` map errors into UI messages.
- **`ConfigService`** — Firebase Remote Config wrapper, initialized at startup and skipped on web.
- **`LocalService`** — `shared_preferences` for client-side settings.

## Cloud Functions

Python, in [functions/](../functions/), deployed to `europe-west1`. `main.py`
holds only trigger definitions.

```text
src/youtube/youtube_client.py   YouTube Data API v3 over requests
src/youtube/block_store.py      reads, routes and writes video blocks
src/youtube/channel_sync.py     fetch → diff → route → write
src/utils/admin_guard.py        meta/{uid}.admin check for callables
```

| Trigger | Kind | Purpose |
| --- | --- | --- |
| `sync_channel` | `on_call`, admin only | `action` of `sync`, `resolve_video` or `resolve_series`. `mode: 'rebuild'` wipes the channel's blocks and re-downloads its full history; the default incremental mode pages the uploads playlist only back to the newest block it already has. |
| `sync_all_channels` | `on_schedule`, daily 03:00 | Incremental sync of every channel. Never rebuilds. |

A channel URL is resolved with an exact `channels.list` lookup (`forHandle` for
`@handle` URLs, `id` otherwise), never a text search, so similarly named channels
cannot be confused. Each sync records the channel it actually resolved to on the
channel doc as `youtubeChannelId` / `youtubeChannelTitle`, and warns if that ever
changes — a channel pointed at the wrong URL shows up in the data rather than
silently filling with another channel's videos.

The YouTube API key lives in Secret Manager as `YOUTUBE_API_KEY` and is bound to
both functions. Set it with `firebase functions:secrets:set YOUTUBE_API_KEY`.

Tests are in [functions/tests/](../functions/tests/). The routing tests are pure
logic; the rest run against the Firestore emulator and skip without it:

```bash
firebase emulators:start --only firestore
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 functions/venv/bin/python -m pytest functions/tests
```

## Video playback

[lib/src/widgets/video_players/youtube_player.dart](../lib/src/widgets/video_players/youtube_player.dart) wraps `youtube_player_iframe` for web and native — same API across platforms. For non-YouTube media, the codebase has `video_player` + `chewie` available but they're not currently wired into a screen.

## Build & deploy

- Web: `firebase deploy --only hosting` (also via GitHub Actions on push to `main` — see `.github/workflows/firebase-hosting-merge.yml`).
- Backend: `firebase deploy --only functions,firestore:rules,firestore:indexes` (also via `.github/workflows/firebase-functions-merge.yml`, which runs on changes under `functions/` or `firebase/`).
- Android/iOS: standard `flutter build apk` / `flutter build ipa`.
- The Android module reads `key.properties` from the project root if present, for release signing. The file is gitignored — see [android/app/build.gradle.kts](../android/app/build.gradle.kts).
