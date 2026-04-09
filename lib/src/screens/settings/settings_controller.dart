import 'package:flutter/material.dart';
import 'package:tldrnews_app/src/services/local_service.dart';

part 'settings_controller.g.dart';

class SettingsController extends ChangeNotifier with SettingsLogic {
  SettingsController() {
    loadAllSettings();
  }
}
