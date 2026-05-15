# TLDR News App

A Flutter video player for TLDR News.

## Local setup

1. Install Flutter (see https://docs.flutter.dev/get-started/install).
2. `cp .env.example .env` and fill in API keys from the Firebase / Google Cloud console:
   - `FIREBASE_WEB_API_KEY`, `FIREBASE_ANDROID_API_KEY`, `FIREBASE_IOS_API_KEY`
   - `YOUTUBE_API_KEY` (YouTube Data API v3, used by admin ingest screens)
3. Generate the platform Firebase config files (not tracked in git):
   - Run `flutterfire configure --project=<your-project>`, or
   - Manually place `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` (downloaded from the Firebase console).
4. `flutter pub get` then `flutter run -d <device>`.

`.env`, `google-services.json`, and `GoogleService-Info.plist` are gitignored — never commit them.
