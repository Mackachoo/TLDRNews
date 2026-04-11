import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

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

      // Set default values
      await _remoteConfig.setDefaults({
        'youtube_api_key': '', // Empty default - will fail if not set in Firebase
      });

      // Fetch and activate latest remote config
      await _remoteConfig.fetchAndActivate();
      _initialized = true;
      debugPrint('ConfigService initialized successfully');
    } catch (error) {
      debugPrint('ConfigService initialization error: $error');
      rethrow;
    }
  }

  /// Get YouTube API key from Remote Config
  static String getYouTubeApiKey() {
    try {
      // On web, Remote Config is unavailable due to dart2js limitations
      // Use hardcoded value from remoteconfig.template.json
      if (kIsWeb) {
        return 'AIzaSyC4PT5oxMmqAsB0Xw6UlXTdAIlZUCD0bb4';
      }

      final apiKey = _remoteConfig.getString('youtube_api_key');
      if (apiKey.isEmpty) {
        throw 'YouTube API key not configured in Firebase Remote Config';
      }
      return apiKey;
    } catch (error) {
      debugPrint('ConfigService.getYouTubeApiKey error: $error');
      // Fallback to hardcoded value if error occurs
      return 'AIzaSyC4PT5oxMmqAsB0Xw6UlXTdAIlZUCD0bb4';
    }
  }
}
