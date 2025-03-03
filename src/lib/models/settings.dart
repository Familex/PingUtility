import 'package:flutter/material.dart';

import '../services/database.dart';

final class Settings extends ChangeNotifier {
  Settings({required int interval}) : _interval = interval;

  int _interval;
  int get interval => _interval;

  set interval(int interval) {
    if (_interval == interval) return;
    _interval = interval;
    notifyListeners();
    DatabaseService().setInterval(interval);
  }
}
