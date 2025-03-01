import 'package:flutter/widgets.dart';

// store host ip or dns name
final class Host {
  Host(this.name);

  final String name;
  bool up = false;
}

final class GlobalState extends ChangeNotifier {
  // FIXME temporary
  final Map<String, Host> hosts = {
    '38.0.101.76': Host('38.0.101.76'),
    '89.0.142.86': Host('89.0.142.86'),
    '237.84.2.178': Host('237.84.2.178'),
    '244.178.44.111': Host('244.178.44.111'),
    '10.8.0.1': Host('10.8.0.1'),
    '192.168.0.1': Host('192.168.0.1'),
    '89.207.132.170': Host('89.207.132.170'),
    'google.com': Host('google.com'),
    'localhost': Host('localhost'),
    '127.0.0.1': Host('127.0.0.1'),
    'amogus': Host('amogus'),
  };
}
