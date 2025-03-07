import 'package:flutter/material.dart';

import '../services/database.dart';

final class Settings extends ChangeNotifier {
  Settings(
      {required int interval,
      required int themeMode,
      required Color themeColor})
      : _interval = interval,
        _themeMode = ThemeMode.values[themeMode],
        _themeColor = themeColor;

  int _interval;
  int get interval => _interval;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  Color _themeColor;
  Color get themeColor => _themeColor;

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

  set themeColor(Color color) {
    if (_themeColor == color) return;
    _themeColor = color;
    notifyListeners();
    DatabaseService().setThemeColor(color);
  }
}
