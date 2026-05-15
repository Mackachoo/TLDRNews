import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Compile-time fallback for the YouTube API key.
  static const String _youtubeApiKeyDefine = String.fromEnvironment('YOUTUBE_API_KEY');

  static bool _initialized = false;

  /// Initialize Remote Config with default values
  /// Call this once during app startup
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Skip Remote Config initialization on web due to dart2js Int64 incompatibility
      if (kIsWeb) {
        debugPrint('ConfigService: Skipping Remote Config on web (dart2js limitation)');
        _initialized = true;
        return;
      }

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults({'youtube_api_key': ''});

      await _remoteConfig.fetchAndActivate();
      _initialized = true;
      debugPrint('ConfigService initialized successfully');
    } catch (error) {
      debugPrint('ConfigService initialization error: $error');
      rethrow;
    }
  }

  /// Get YouTube API key. Resolution order:
  ///   1. `.env` (loaded by flutter_dotenv) — local dev convenience.
  ///   2. `--dart-define=YOUTUBE_API_KEY=...` (compile-time) — CI builds.
  ///   3. Firebase Remote Config — production rotation on mobile.
  static String getYouTubeApiKey() {
    try {
      final fromEnv = dotenv.env['YOUTUBE_API_KEY'];
      if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    } catch (_) {
      // dotenv not initialised; fall through.
    }

    if (_youtubeApiKeyDefine.isNotEmpty) return _youtubeApiKeyDefine;

    if (kIsWeb) {
      throw StateError(
        'YOUTUBE_API_KEY not set. Put it in .env or pass --dart-define=YOUTUBE_API_KEY=...',
      );
    }

    final remoteKey = _remoteConfig.getString('youtube_api_key');
    if (remoteKey.isNotEmpty) return remoteKey;

    throw StateError(
      'YouTube API key not configured. Set it in .env, pass --dart-define=YOUTUBE_API_KEY=..., '
      'or set youtube_api_key in Firebase Remote Config.',
    );
  }
}
