import 'package:flutter/material.dart';
// import 'package:skiwi_share/localizations.dart';

extension LocaleExtension on BuildContext {
  // AppLocalizations get locale => AppLocalizations.of(this)!;

  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
}
