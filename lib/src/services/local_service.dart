import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  //* Defaults =======================================================

  static Future clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // String
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future setString(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }

  static Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future setStringList(String key, List<String>? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setStringList(key, value);
    }
  }

  static Future addStringStack(String key, String value, {int? maxLength}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> current = (prefs.getStringList(key) ?? [])
        .where((e) => e != value)
        .take((maxLength ?? 100) - 1)
        .toList();
    await prefs.setStringList(key, [value, ...current]);
  }

  // Bool
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future setBool(String key, bool? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setBool(key, value);
    }
  }

  // Int
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future setInt(String key, int? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setInt(key, value);
    }
  }

  // Double
  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future setDouble(String key, double? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setDouble(key, value);
    }
  }

  //* Custom =======================================================

  // Colour
  static Future<Color?> getColor(String key) async {
    final a = await getInt('${key}_A');
    final r = await getInt('${key}_R');
    final g = await getInt('${key}_G');
    final b = await getInt('${key}_B');
    if (a == null || r == null || g == null || b == null) return null;
    return Color.fromARGB(a, r, g, b);
  }

  static Future setColor(String key, Color? colour) async {
    await setInt('${key}_R', colour?.r.round());
    await setInt('${key}_G', colour?.g.round());
    await setInt('${key}_B', colour?.b.round());
    await setInt('${key}_A', colour?.a.round());
  }

  // DateTime
  static Future<DateTime?> getDateTime(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return DateTime.parse(value);
  }

  static Future setDateTime(String key, DateTime? value) =>
      setString(key, value?.toIso8601String());

  // Theme
  static Future<ThemeMode?> getThemeMode(String key) async {
    switch (await getString(key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static Future setThemeMode(String key, ThemeMode? theme) => setString(key, theme?.name);
}
