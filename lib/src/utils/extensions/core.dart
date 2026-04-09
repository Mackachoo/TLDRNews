import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

//* General Extensions -----------------------------------

extension RouterExtension on GoRouter {
  Future<T?> add<T extends Object?>(String added, {Object? extra, String? fallback}) async {
    String base = routerDelegate.currentConfiguration.uri.path;
    if (!base.endsWith('/')) base += '/';
    final String location = base + added;

    return routeInformationProvider.push<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  void forcePop<T extends Object?>([T? result]) {
    if (routerDelegate.canPop()) {
      routerDelegate.pop<T>(result);
      restore(routerDelegate.currentConfiguration);
    } else {
      go('/');
    }
  }

  void goParams(Map<String, String> params, {Object? extra}) {
    Map<String, String> newParams = {}
      ..addAll(state.uri.queryParameters)
      ..addAll(params);
    final uri = state.uri.replace(queryParameters: newParams);
    routeInformationProvider.go(uri.toString(), extra: extra);
  }
}

extension StringExtension on String {
  String capitalize() =>
      length == 1 ? toUpperCase() : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String toInitials() {
    List<String> parts = split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts.map((part) => part[0].toUpperCase()).take(2).join();
  }
}

extension DateTimeExtension on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  int daysAgo() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

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

  String toUser() {
    String date = '';
    if (!isToday()) {
      if (isYesterday()) {
        date = ' yesterday';
      } else {
        if (daysAgo() < 7) {
          date = ' $weekdayName';
        } else {
          date = ' ${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}';
          if (!isThisYear()) date = '/$year';
        }
      }
    }
    return '$hour:${minute.toString().padLeft(2, '0')}$date';
  }
}

extension ColorExtension on Color {
  String get hhex => '#$hex';
  String get hex => toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2);
}

extension IterableExt<E> on Iterable<E> {
  /// The first element satisfying [test], or `null` if there are none.
  E? firstWhereOrNull(bool Function(E element) test) => where(test).firstOrNull;
}
