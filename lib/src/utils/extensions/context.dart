import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tldrnews_app/src/utils/extensions/core.dart';
// import 'package:skiwi_share/localizations.dart';

extension LocaleExtension on BuildContext {
  // AppLocalizations get locale => AppLocalizations.of(this)!;

  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;

  // GoRouter
  Future<T?> add<T extends Object?>(String added, {Object? extra}) =>
      GoRouter.of(this).add(added, extra: extra);
  void forcePop<T extends Object?>([T? result]) => GoRouter.of(this).forcePop(result);
  void goParams(Map<String, String> params, {Object? extra}) =>
      GoRouter.of(this).goParams(params, extra: extra);
  Uri get uri => GoRouterState.of(this).uri;
}
