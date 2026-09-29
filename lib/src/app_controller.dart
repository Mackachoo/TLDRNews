import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/screens/auth/auth_controller.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/settings/settings_controller.dart';

/// Singleton root of the app's long-lived state.
///
/// Holds the controllers that outlive any single screen: [auth], [settings] and
/// a [ChannelController] per channel, created on first use by [channel].
class AppCtlr {
  static final AppCtlr _instance = AppCtlr._internal();
  factory AppCtlr() => _instance;
  AppCtlr._internal() {
    // Wire up routing refresh
    // auth.addListener(notifyListeners);
  }

  //* System-Wide Controllers -------------------------

  /// Signed-in user, their account document and their [Meta] permissions.
  final auth = AuthController();

  /// User preferences persisted on the device.
  final settings = SettingsController();

  /// Channel controllers keyed by channel id.
  final channels = <String, ChannelController>{};

  /// The controller for [snippet]'s channel, created and cached on first request
  /// so revisiting a channel keeps its loaded videos.
  ChannelController channel(ChannelSnippet snippet) =>
      channels.putIfAbsent(snippet.id, () => ChannelController(snippet));

  //* System-Wide Shortcuts ----------------------------------

  // @override
  // Duration get duration =>\
  //     settings.appearance.animations ? Duration(milliseconds: 300) : Duration(milliseconds: 1);

  // @override
  // bool get animations => settings.appearance.animations;
}
