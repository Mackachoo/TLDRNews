// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from settings_controller.json

part of 'settings_controller.dart';

mixin SettingsLogic on ChangeNotifier {

  final AppearanceSettingsController _appearance = AppearanceSettingsController();
  final NotificationsSettingsController _notifications = NotificationsSettingsController();

  AppearanceSettingsController get appearance => _appearance;
  NotificationsSettingsController get notifications => _notifications;

  Future<void> loadAllSettings() async {
    await _appearance.loadSettings();
    _appearance.addListener(notifyListeners);
    await _notifications.loadSettings();
    _notifications.addListener(notifyListeners);
    notifyListeners();
  }

  @override
  void dispose() {
    _appearance.removeListener(notifyListeners);
    _appearance.dispose();
    _notifications.removeListener(notifyListeners);
    _notifications.dispose();
    super.dispose();
  }
}
class AppearanceSettingsController with ChangeNotifier {
  AppearanceSettingsController();

  ThemeMode _theme = ThemeMode.light;

  Future<void> loadSettings() async {
    final storedTheme = await LocalService.getThemeMode('appearance_theme');
    _theme = storedTheme ?? ThemeMode.light;
    notifyListeners();
  }

  void notify() => notifyListeners();

  ThemeMode get theme => _theme;
  set theme(ThemeMode newValue) {
    if (newValue != _theme) {
      _theme = newValue;
      notifyListeners();
      LocalService.setThemeMode('appearance_theme', newValue);
    }
  }

}

class NotificationsSettingsController with ChangeNotifier {
  NotificationsSettingsController();

  bool _all = false;

  Future<void> loadSettings() async {
    final storedAll = await LocalService.getBool('notifications_all');
    _all = storedAll ?? false;
    notifyListeners();
  }

  void notify() => notifyListeners();

  bool get all => _all;
  set all(bool newValue) {
    if (newValue != _all) {
      _all = newValue;
      notifyListeners();
      LocalService.setBool('notifications_all', newValue);
    }
  }

}

