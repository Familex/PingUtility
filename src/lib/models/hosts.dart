import 'dart:async';
import 'dart:collection';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

import 'settings.dart';

class Host {
  Host(this.name);

  final String name;
  List<Duration?> time = [];
}

const timeoutMs = 3000;
const pingHistoryMax = 100;
const smallGraphElements = 20;

final class HostsModel extends ChangeNotifier {
  Ping _createPing(Host host, int interval) {
    var ping = Ping(host.name, count: null, interval: interval);
    ping.stream.listen((event) {
      if (event.response == null) return;
      host.time.add(event.response!.time);
      if (host.time.length > pingHistoryMax) {
        host.time.removeAt(0);
      }
      notifyListeners();
    });
    return ping;
  }

  late Settings _settings;
  Settings get settings => _settings;
  set settings(Settings settings) {
    _settings = settings;
    _hosts.forEach((key, value) {
      unawaited(() async {
        await value.$1.stop();
        var ping = _createPing(value.$2, settings.interval);
        value = (ping, value.$2);
      }.call());
    });

    // FIXME move to database
    if (_hosts.isEmpty) {
      addHost(Host('localhost'));
      addHost(Host('127.0.0.1'));
      addHost(Host('1.1.1.1'));
      addHost(Host('google.com'));
      // FIXME temporary
      addHost(Host('38.0.101.76'));
      addHost(Host('89.0.142.86'));
      addHost(Host('237.84.2.178'));
      addHost(Host('244.178.44.111'));
      addHost(Host('10.8.0.1'));
      addHost(Host('192.168.0.1'));
      addHost(Host('89.207.132.170'));
      addHost(Host('INVALID'));
    }

    notifyListeners();
  }

  final Map<String, (Ping, Host)> _hosts = {};
  UnmodifiableMapView<String, (Ping, Host)> get hosts =>
      UnmodifiableMapView(_hosts);

  UnmodifiableListView<Duration?> getGraphDataReversed(String hostName) =>
      UnmodifiableListView(
          _hosts[hostName]?.$2.time.reversed.take(smallGraphElements) ?? []);

  void addHost(Host host) {
    var ping = _createPing(host, settings.interval);
    _hosts[host.name] = (ping, host);
    notifyListeners();
  }
}
