import 'package:tldrnews_app/src/objects/channel/snippets.dart';
import 'package:tldrnews_app/src/screens/auth/auth_controller.dart';
import 'package:tldrnews_app/src/screens/channels/channel_controller.dart';
import 'package:tldrnews_app/src/screens/settings/settings_controller.dart';
import 'package:tldrnews_app/src/utils/youtube_controller.dart';

class AppCtlr {
  static final AppCtlr _instance = AppCtlr._internal();
  factory AppCtlr() => _instance;
  AppCtlr._internal() {
    // Wire up routing refresh
    // auth.addListener(notifyListeners);
  }

  //* System-Wide Controllers -------------------------

  final auth = AccountController();
  final settings = SettingsController();

  final youtube = YoutubeController();
  final channels = <String, ChannelController>{};
  ChannelController channel(ChannelSnippet snippet) =>
      channels.putIfAbsent(snippet.id, () => ChannelController(snippet));

  //* System-Wide Shortcuts ----------------------------------

  // @override
  // Duration get duration =>\
  //     settings.appearance.animations ? Duration(milliseconds: 300) : Duration(milliseconds: 1);

  // @override
  // bool get animations => settings.appearance.animations;
}
