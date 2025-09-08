import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'jour_nwal_theme';
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    // 0 = system (unused), 1 = light, 2 = dark
    await sp.setInt(_key, mode == ThemeMode.dark ? 2 : 1);
  }

  static Future<ThemeMode> getSavedThemeMode() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getInt(_key) ?? 1;
    return v == 2 ? ThemeMode.dark : ThemeMode.light;
  }
}
  