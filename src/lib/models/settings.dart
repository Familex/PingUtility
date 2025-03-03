import 'package:flutter/material.dart';

final class Settings extends ChangeNotifier {
  Settings({required int interval}) : _interval = interval;

  int _interval;
  int get interval => _interval;

  set interval(int interval) {
    if (_interval == interval) return;
    _interval = interval;
    notifyListeners();
  }
}
