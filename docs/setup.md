# Local setup

Step-by-step guide to running the app from a fresh clone.

## Prerequisites

- Flutter SDK `^3.11.0` (`flutter --version`)
- A Firebase project you own — you cannot run against the production `tldr-news-229ac` project
- For mobile: Xcode (iOS) and/or Android Studio with an SDK + emulator
- The `flutterfire` CLI: `dart pub global activate flutterfire_cli`

## 1. Clone and install dependencies

```bash
git clone https://github.com/<you>/TLDRNews-App.git
cd TLDRNews-App
flutter pub get
```

## 2. Create a Firebase project

In the [Firebase console](https://console.firebase.google.com):

1. Create a project (or reuse one).
2. Enable **Authentication** → Email/Password and Google providers.
3. Enable **Cloud Firestore** in `eur3` (or update `firebase.json`).
4. Enable **Remote Config**.
5. (Optional) Enable **App Check** for production hardening.
6. Register an app for each platform you'll run (web, Android, iOS) and note the appIds.

## 3. Generate platform config

From the repo root:

```bash
flutterfire configure --project=<your-firebase-project-id>
```

This writes:

- `lib/firebase_options.dart` — but `flutterfire configure` will overwrite the `apiKey:` fields with literals. After running it, replace each `apiKey: '...'` with `apiKey: String.fromEnvironment('FIREBASE_<PLATFORM>_API_KEY')` so the keys come from `--dart-define` (see step 4) instead of being committed to source.
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

All three are gitignored. Re-run `flutterfire configure` whenever your Firebase project changes.

## 4. Fill in `.env`

```bash
cp .env.example .env
```

The app reads `.env` at runtime via `flutter_dotenv` when present, and falls back to `--dart-define` values otherwise. Locally you can just keep a populated `.env` and skip the build flags. Populate every variable:

- **`FIREBASE_WEB_API_KEY`** — Firebase console, *Project settings → Web app → SDK setup → `apiKey`*.
- **`FIREBASE_ANDROID_API_KEY`** — `android/app/google-services.json`, field `client[0].api_key[0].current_key`.
- **`FIREBASE_IOS_API_KEY`** — `ios/Runner/GoogleService-Info.plist`, field `API_KEY`.
- **`YOUTUBE_API_KEY`** — [Google Cloud Credentials](https://console.cloud.google.com/apis/credentials): create a new API key and restrict it to **YouTube Data API v3**.

## 5. Restrict your keys (do this before going public)

In Google Cloud → Credentials, edit each key:

- **Web key** — Application restriction: HTTP referrers — `localhost:*`, your deploy domain.
- **Android key** — Application restriction: Android apps — package `com.tldrnews.app` + your debug + release SHA-1 fingerprints (`./gradlew signingReport`).
- **iOS key** — Application restriction: iOS apps — bundle ID `com.tldrnews.app`.
- **YouTube key** — API restriction: YouTube Data API v3 only. Application restriction matching whichever platform calls it (admin web/mobile).

Without restrictions, a leaked key is fully usable by anyone.

## 6. Seed Firestore

The app expects:

- `meta/{uid}` — `{ admin: true }` for any admin user. Create your own doc manually after first sign-in.
- `channels/{cid}` — channel documents. The admin UI creates these once you grant yourself admin.

Deploy the Firestore rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 7. Run

Locally, the app loads `.env` at runtime — just populate it and run:

```bash
flutter run -d chrome
flutter run -d <android>
flutter run -d <ios>
```

If `.env` is missing or a value is blank, the code falls back to `--dart-define` at compile time. So this also works:

```bash
flutter build web --dart-define=FIREBASE_WEB_API_KEY=... --dart-define=YOUTUBE_API_KEY=...
```

That's the path CI uses (see [.github/workflows/firebase-hosting-merge.yml](../.github/workflows/firebase-hosting-merge.yml)) — secrets come from GitHub and are passed as compile-time defines.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `[firebase_core/invalid-api-key]` or empty `apiKey` | `.env` is missing/blank and no `--dart-define` was passed. Populate `.env` or pass the keys at build time. |
| `PlatformException(channel-error...)` on launch | `google-services.json` or `GoogleService-Info.plist` not in place. Re-run `flutterfire configure`. |
| `403` from YouTube Data API | Key is restricted to the wrong API, wrong referrer, or quota exhausted. Check the GCP key's "Restrictions" tab. |
| Admin routes redirect to `/` | Your `meta/{uid}` doc is missing or `admin != true`. |
