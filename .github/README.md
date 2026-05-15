<div align="center">
  <img src="../assets/logos/tldr-white.png" alt="TLDR News" width="120" />

  # TLDR News

  A cross-platform video player for the TLDR News network.

  Built with Flutter, Firebase, and the YouTube Data API. One codebase, three targets: web, Android, iOS.

  [Setup](../docs/setup.md) · [Architecture](../docs/architecture.md) · [Security](../docs/security.md)
</div>

---

## Features

- **Channel browsing** — every TLDR News channel (Global, EU, UK, Party, etc.) with its full back-catalogue and curated series/playlists.
- **In-app player** — YouTube playback via `youtube_player_iframe` on web and embedded video on mobile.
- **Auth** — email/password and Google sign-in via Firebase Auth.
- **Admin console** — admins can add channels, ingest a YouTube channel's uploads + playlists in one click, and manage users.
- **Light / dark themes** with custom typography (Assistant, Figtree).
- **Live config** — YouTube API key rotation via Firebase Remote Config without shipping a new build.

## Tech stack

| Layer            | Tooling                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| Framework        | Flutter (Dart `^3.11.0`)                                                |
| Routing          | `go_router`                                                             |
| State            | `ChangeNotifier` + `ListenableBuilder`                                  |
| Backend          | Firebase Auth, Cloud Firestore, Remote Config, App Check, Analytics    |
| Hosting          | Firebase Hosting (deployed via GitHub Actions on merge to `main`)      |
| Video            | `youtube_player_iframe`, `video_player`, `chewie`                      |
| Serialisation    | `json_serializable` / `build_runner`                                   |
| Icons            | `phosphor_flutter`                                                     |
| Secrets          | `--dart-define` (build-time) + Firebase Remote Config (runtime)        |

## Quick start

```bash
git clone https://github.com/<you>/TLDRNews-App.git
cd TLDRNews-App
cp .env.example .env          # then fill in your keys
flutterfire configure         # regenerates google-services.json / GoogleService-Info.plist
flutter pub get
flutter run -d chrome --dart-define-from-file=.env
```

Full instructions, including Firebase project setup and platform tooling: **[docs/setup.md](docs/setup.md)**.

## Project layout

```
lib/
  main.dart              # entry point, initialises Firebase
  firebase_options.dart  # platform Firebase config (API keys via --dart-define)
  src/
    app.dart             # MaterialApp + GoRouter
    app_controller.dart  # top-level AppCtlr (auth, settings, channels)
    app_shell.dart       # bottom nav / app chrome
    objects/             # data models (json_serializable)
    screens/             # auth, home, channel, video, settings, admin
    services/            # firestore, auth, youtube, remote config
    widgets/             # reusable UI + video player wrappers
    utils/               # theme, extensions
firebase/                # Firestore rules + indexes
docs/                    # extended documentation
```

A guided tour of how data flows from Firestore through controllers into the UI: **[docs/architecture.md](docs/architecture.md)**.

## Security model

- API keys live in a gitignored `.env` consumed at build time via `--dart-define-from-file=.env`, never bundled as an asset. Production rotation goes through Firebase Remote Config.
- Platform Firebase config files (`google-services.json`, `GoogleService-Info.plist`) are gitignored and regenerated locally with `flutterfire configure`.
- Firestore rules enforce per-user document access and an admin role gate.
- Production safety relies on **API-key restrictions in Google Cloud Console** — referrers for web, package + SHA-1 for Android, bundle ID for iOS.

Details and the full threat model: **[docs/security.md](docs/security.md)**.

## Contributing

Issues and PRs welcome. Please:

1. Open an issue describing the change before any non-trivial work.
2. Run `flutter analyze` and `dart format .` before pushing.
3. Don't commit `.env`, `google-services.json`, `GoogleService-Info.plist`, or anything matching `AIza[0-9A-Za-z_-]{35}`.

## Acknowledgements

- The [TLDR News](https://www.youtube.com/@TLDRnewsGlobal) team for the source material.
- The Flutter, Firebase, and YouTube Data API teams.
