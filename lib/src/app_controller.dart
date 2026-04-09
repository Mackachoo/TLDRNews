import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/screens/settings/settings_controller.dart';

class AppCtlr with ChangeNotifier {
  static final AppCtlr _instance = AppCtlr._internal();
  factory AppCtlr() => _instance;
  AppCtlr._internal() {
    // Wire up routing refresh
    // auth.addListener(notifyListeners);
  }

  //* System-Wide Controllers -------------------------

  // late final AuthController auth = AuthController();
  // late final HomeController home = HomeController();
  late final SettingsController settings = SettingsController();

  //* System-Wide Shortcuts ----------------------------------

  // @override
  // Duration get duration =>\
  //     settings.appearance.animations ? Duration(milliseconds: 300) : Duration(milliseconds: 1);

  // @override
  // bool get animations => settings.appearance.animations;
}
