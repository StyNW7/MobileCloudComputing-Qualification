import 'package:flutter/material.dart';
import '../utils/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode;
  ThemeProvider(this._mode);

  ThemeMode get mode => _mode;

  void setMode(ThemeMode newMode) {
    _mode = newMode;
    ThemeService.saveThemeMode(newMode);
    notifyListeners();
  }
}
