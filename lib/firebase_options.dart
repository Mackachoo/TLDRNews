import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// API keys are resolved at runtime in priority order:
///   1. `.env` (loaded by `flutter_dotenv` in [main]) — preferred for local dev.
///   2. `--dart-define=KEY=...` (compile-time) — used by CI builds.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // Compile-time fallbacks, used when .env isn't loaded or is missing the key.
  static const _webApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const _androidApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _iosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');

  static String _resolve(String key, String compileTime) {
    try {
      final v = dotenv.env[key];
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {
      // dotenv not initialised; fall through.
    }
    return compileTime;
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _resolve('FIREBASE_WEB_API_KEY', _webApiKey),
    appId: '1:628191602084:web:c66559dbbf91c2d9d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    authDomain: 'tldr-news-229ac.firebaseapp.com',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
    measurementId: 'G-RW9ZKB7QBF',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _resolve('FIREBASE_ANDROID_API_KEY', _androidApiKey),
    appId: '1:628191602084:android:1e26641b7bbe63f3d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _resolve('FIREBASE_IOS_API_KEY', _iosApiKey),
    appId: '1:628191602084:ios:ffe8b725b37c17d6d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
    iosBundleId: 'com.tldrnews.app',
  );
}
