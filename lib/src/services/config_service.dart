import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class ConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static bool _initialized = false;

  /// Initialize Remote Config with default values.
  /// Call this once during app startup. Never throws: an offline start or an
  /// expired Firebase API key must not block the app.
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

      await _remoteConfig.fetchAndActivate();
      _initialized = true;
      debugPrint('ConfigService initialized successfully');
    } catch (error) {
      debugPrint('ConfigService initialization error: $error');
    }
  }
}
