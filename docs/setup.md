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

- `lib/firebase_options.dart` — but `flutterfire configure` will overwrite the `apiKey:` fields with literals. After running it, restore each one to `apiKey: _resolve('FIREBASE_<PLATFORM>_API_KEY', _<platform>ApiKey)` so the keys come from `.env` (see step 4) instead of being committed to source.
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

All three are gitignored. Re-run `flutterfire configure` whenever your Firebase project changes.

## 4. Fill in `.env`

```bash
cp .env.example .env
```

`.env` is read at **build time** via `--dart-define-from-file=.env`; it is not bundled with the app. Populate every variable:

- **`FIREBASE_WEB_API_KEY`** — Firebase console, *Project settings → Web app → SDK setup → `apiKey`*.
- **`FIREBASE_ANDROID_API_KEY`** — `android/app/google-services.json`, field `client[0].api_key[0].current_key`.
- **`FIREBASE_IOS_API_KEY`** — `ios/Runner/GoogleService-Info.plist`, field `API_KEY`.
The YouTube key is **not** one of these — it lives in Secret Manager and is only ever read by the Cloud Function (see step 6).

## 5. Restrict your keys (do this before going public)

In Google Cloud → Credentials, edit each key:

- **Web key** — Application restriction: HTTP referrers — `localhost:*`, your deploy domain.
- **Android key** — Application restriction: Android apps — package `com.tldrnews.app` + your debug + release SHA-1 fingerprints (`./gradlew signingReport`).
- **iOS key** — Application restriction: iOS apps — bundle ID `com.tldrnews.app`.
- **YouTube key** — API restriction: YouTube Data API v3 only. It is called from the Cloud Function, never the client, so it needs no application restriction.

Without restrictions, a leaked key is fully usable by anyone.

## 6. Seed Firestore

The app expects:

- `meta/{uid}` — `{ admin: true }` for any admin user. Create your own doc manually after first sign-in.
- `channels/{cid}` — channel documents. The admin UI creates these once you grant yourself admin.

Deploy the Firestore rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### Cloud Functions

Video ingestion runs server-side. Create a YouTube Data API v3 key in
[Google Cloud Credentials](https://console.cloud.google.com/apis/credentials),
store it as a secret, and deploy:

```bash
firebase functions:secrets:set YOUTUBE_API_KEY
firebase deploy --only functions
```

Party approval signs its challenges with a second secret. Any long random string
works; rotating it invalidates every open challenge but no existing membership:

```bash
openssl rand -hex 32 | firebase functions:secrets:set PARTY_APPROVAL_SECRET
```

Then open `/admin/channel/<id>` and press **Rebuild** once per channel to pull
the full history into video blocks. **Fetch** afterwards only picks up what is
new, and the daily schedule does the same automatically.

To work on the functions locally:

```bash
cd functions
python3 -m venv venv
venv/bin/pip install -r requirements.txt -r requirements-dev.txt
venv/bin/python -m pytest tests
```

## 7. Run

Pass `.env` on every run and build:

```bash
flutter run -d chrome --dart-define-from-file=.env
flutter run -d <android> --dart-define-from-file=.env
flutter build web --dart-define-from-file=.env
```

In VS Code the bundled launch configurations in [.vscode/launch.json](../.vscode/launch.json) already carry the flag, so the run button just works.

To override a value without touching `.env`, add a gitignored `.env.local` and pass both — the last file wins:

```bash
flutter run --dart-define-from-file=.env --dart-define-from-file=.env.local
```

CI passes the same values as individual `--dart-define`s from GitHub secrets, so no `.env` exists on the runner (see [.github/workflows/firebase-hosting-merge.yml](../.github/workflows/firebase-hosting-merge.yml)).

### Running against the emulators

Set `USE_FIREBASE_EMULATOR=true` in `.env`, then:

```bash
firebase emulators:start
flutter run -d chrome --dart-define-from-file=.env
```

Firestore is expected on `127.0.0.1:8080` and functions on `5001`. Override the host with `FIREBASE_EMULATOR_HOST` (an Android emulator needs `10.0.2.2`).

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Assertion: `FIREBASE_..._API_KEY is not set` | You ran without `--dart-define-from-file=.env`, or that key is blank in `.env`. |
| `[firebase_core/invalid-api-key]` in a release build | Same cause, but asserts are stripped from release builds so it surfaces later. Check the build command carries the flag. |
| `PlatformException(channel-error...)` on launch | `google-services.json` or `GoogleService-Info.plist` not in place. Re-run `flutterfire configure`. |
| `403` from YouTube Data API | Key is restricted to the wrong API, wrong referrer, or quota exhausted. Check the GCP key's "Restrictions" tab. |
| Admin routes redirect to `/` | Your `meta/{uid}` doc is missing or `admin != true`. |
