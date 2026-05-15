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
| `/video/:id`        | `VideoScreen`                | Full-screen player (outside shell)|

A `redirect` callback rejects `/admin/**` for non-admin users.

## Data model

Stored in Cloud Firestore (`eur3`):

```
accounts/{uid}    — user profile, preferences (per-user, owner-only RW)
meta/{uid}        — { admin: bool, ... } (readable by any auth'd user, writable only by admins)
channels/{cid}    — channel doc (public read, admin-only write)
  ├─ name, channelUrl, description
  ├─ videos: { videoId → YoutubeVideo }
  └─ series:  { playlistId → Series }
```

Dart classes live in [lib/src/objects/](../lib/src/objects/) and use `json_serializable`. Regenerate with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`Channel` extends `ChannelSnippet` so list views can render quickly with just `{id, name}` without hydrating the full video map.

## Services

- **`FirestoreService`** + per-collection modules in `services/firestore/` — typed reads/writes; no caching layer (Firestore SDK handles it).
- **`AuthService`** — wraps `firebase_auth` and `google_sign_in`. Returns `UserCredential` and lets `AuthController` map errors into UI messages.
- **`YouTubeService`** — direct REST calls to `https://www.googleapis.com/youtube/v3`. Used only by admin screens for channel ingestion. Key resolved via `ConfigService`.
- **`ConfigService`** — Firebase Remote Config wrapper. Prefers `.env` for the YouTube key, falls back to Remote Config on mobile.
- **`LocalService`** — `shared_preferences` for client-side settings.

## Video playback

[lib/src/widgets/video_players/youtube_player.dart](../lib/src/widgets/video_players/youtube_player.dart) wraps `youtube_player_iframe` for web and native — same API across platforms. For non-YouTube media, the codebase has `video_player` + `chewie` available but they're not currently wired into a screen.

## Build & deploy

- Web: `firebase deploy --only hosting` (also via GitHub Actions on push to `main` — see `.github/workflows/`).
- Android/iOS: standard `flutter build apk` / `flutter build ipa`.
- The Android module reads `key.properties` from the project root if present, for release signing. The file is gitignored — see [android/app/build.gradle.kts](../android/app/build.gradle.kts).
