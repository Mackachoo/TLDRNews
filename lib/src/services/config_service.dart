import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class ConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static bool _initialized = false;

  /// Initialize Remote Config with default values
  /// Call this once during app startup
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
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
      final apiKey = _remoteConfig.getString('youtube_api_key');
      if (apiKey.isEmpty) {
        throw 'YouTube API key not configured in Firebase Remote Config';
      }
      return apiKey;
    } catch (error) {
      debugPrint('ConfigService.getYouTubeApiKey error: $error');
      rethrow;
    }
  }
}
