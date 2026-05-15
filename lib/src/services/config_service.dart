import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

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

  /// Get YouTube API key. Prefers .env (bundled at build time); falls back to
  /// Firebase Remote Config so the key can be rotated without shipping a new build.
  static String getYouTubeApiKey() {
    final envKey = dotenv.env['YOUTUBE_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) return envKey;

    if (kIsWeb) {
      throw StateError('YouTube API key not configured. Set YOUTUBE_API_KEY in .env');
    }

    final remoteKey = _remoteConfig.getString('youtube_api_key');
    if (remoteKey.isNotEmpty) return remoteKey;

    throw StateError(
      'YouTube API key not configured. Set YOUTUBE_API_KEY in .env or '
      'youtube_api_key in Firebase Remote Config.',
    );
  }
}
