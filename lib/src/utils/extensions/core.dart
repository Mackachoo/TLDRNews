import 'dart:collection';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

/// A decoded JSON object.
typedef Json = Map<String, dynamic>;

//* General Extensions -----------------------------------

/// Navigation helpers that keep the current location in the URL.
extension RouterExtension on GoRouter {
  /// Pushes [added] as a child of the current path, e.g. `/channel/uk` plus
  /// `video/x` becomes `/channel/uk/video/x`.
  Future<T?> add<T extends Object?>(String added, {Object? extra}) async {
    String base = routerDelegate.currentConfiguration.uri.path;
    if (!base.endsWith('/')) base += '/';
    final String location = base + added;

    return routeInformationProvider.push<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Pops the top route and syncs the URL, or goes to `/` if nothing can pop.
  void forcePop<T extends Object?>([T? result]) {
    if (routerDelegate.canPop()) {
      routerDelegate.pop<T>(result);
      restore(routerDelegate.currentConfiguration);
    } else {
      go('/');
    }
  }

  /// Navigates to the current path with [params] merged over its existing query
  /// parameters.
  void goParams(Map<String, String> params, {Object? extra}) {
    Map<String, String> newParams = {}
      ..addAll(state.uri.queryParameters)
      ..addAll(params);
    final uri = state.uri.replace(queryParameters: newParams);
    routeInformationProvider.go(uri.toString(), extra: extra);
  }
}

/// Display helpers for strings.
extension StringExtension on String {
  /// First letter upper case, the rest lower case.
  String capitalize() =>
      length == 1 ? toUpperCase() : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Up to two initials from the words, e.g. `Ada Lovelace` becomes `AL`.
  String toInitials() {
    List<String> parts = split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts.map((part) => part[0].toUpperCase()).take(2).join();
  }
}

/// Relative-date helpers, all measured against the local clock.
extension DateTimeExtension on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Whole days elapsed since this date; negative if it is in the future.
  int daysAgo() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

  /// Whole days until this date; negative if it has passed.
  int daysToGo() {
    final now = DateTime.now();
    return difference(now).inDays;
  }

  bool isThisYear() {
    final now = DateTime.now();
    return year == now.year;
  }

  String get weekdayName {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[(weekday - 1) % 7];
  }

  /// Compact label: the time today, `yesterday`, the weekday within the last
  /// week, else `dd/mm/yyyy`.
  String toUI() {
    if (isToday()) return '$hour:${minute.toString().padLeft(2, '0')}';
    if (isYesterday()) return 'yesterday';
    if (daysAgo() < 7) return weekdayName;
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}

/// Hex formatting for colours.
extension ColorExtension on Color {
  /// Hex with a leading `#`, without alpha, e.g. `#4EA4AC`.
  String get hhex => '#$hex';
  /// Upper-case RGB hex without alpha or `#`.
  String get hex => toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2);
}

extension IterableExt<E> on Iterable<E> {
  /// The first element satisfying [test], or `null` if there are none.
  E? firstWhereOrNull(bool Function(E element) test) => where(test).firstOrNull;
}
