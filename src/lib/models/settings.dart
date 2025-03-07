import 'package:flutter/material.dart';

import '../services/database.dart';

final class Settings extends ChangeNotifier {
  Settings({
    required int interval,
    required int themeMode,
    required Color? customColor,
  })  : _interval = interval,
        _themeMode = ThemeMode.values[themeMode],
        _customThemeColor = customColor;

  int _interval;
  int get interval => _interval;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  Color? _customThemeColor;
  Color? get customThemeColor => _customThemeColor;

  set interval(int interval) {
    if (_interval == interval) return;
    _interval = interval;
    notifyListeners();
    DatabaseService().setInterval(interval);
  }

  set themeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
    DatabaseService().setThemeMode(themeMode);
  }

  set customThemeColor(Color? color) {
    if (_customThemeColor == color) return;
    _customThemeColor = color;
    notifyListeners();
    DatabaseService().setCustomThemeColor(color);
  }
}
