import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVmwq6WCbP0gyZ5IE_MFwgDHGgg6qAkvQ',
    appId: '1:628191602084:web:c66559dbbf91c2d9d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    authDomain: 'tldr-news-229ac.firebaseapp.com',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
    measurementId: 'G-RW9ZKB7QBF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC29MnnNOIDPEuVMHkXzopjiQYE6W6NESk',
    appId: '1:628191602084:android:1e26641b7bbe63f3d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsh4gwgw7KfHlqzraluF-CVz-ZMKwSVK0',
    appId: '1:628191602084:ios:ffe8b725b37c17d6d64d31',
    messagingSenderId: '628191602084',
    projectId: 'tldr-news-229ac',
    storageBucket: 'tldr-news-229ac.firebasestorage.app',
    iosBundleId: 'com.tldrnews.app',
  );
}
