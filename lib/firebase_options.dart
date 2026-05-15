import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
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

  static String _requireEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing $key in .env — see .env.example');
    }
    return value;
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_WEB_API_KEY'),
    appId: '1:628191602084:web:c66559dbbf91c2d9d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    authDomain: 'tldr-news-229ac.firebaseapp.com',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
    measurementId: 'G-RW9ZKB7QBF',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_ANDROID_API_KEY'),
    appId: '1:628191602084:android:1e26641b7bbe63f3d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_IOS_API_KEY'),
    appId: '1:628191602084:ios:ffe8b725b37c17d6d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
    iosBundleId: 'com.tldrnews.app',
  );
}
