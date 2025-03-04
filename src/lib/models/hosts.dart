import 'dart:async';
import 'dart:collection';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';
import 'settings.dart';

class Host {
  Host({
    required this.hostname,
    this.displayName,
    this.pingInterval,
  });

  final String hostname;
  final String? displayName;
  final int? pingInterval;

  List<Duration?> time = [];
  (Ping, StreamSubscription<PingData>)? ping;

  get graphDataReversed =>
      UnmodifiableListView(time.reversed.take(smallGraphElements));
}

const timeoutMs = 3000;
const pingHistoryMax = 100;
const smallGraphElements = 20;

final class HostsModel extends ChangeNotifier {
  final Map<String, Host> _hosts = {};
  late Settings _settings;
  bool _initialLoading = true;

  bool get isInitialLoading => _initialLoading;
  Settings get settings => _settings;
  UnmodifiableMapView<String, Host> get hosts =>
      UnmodifiableMapView(_initialLoading ? {} : _hosts);
  UnmodifiableListView<Duration?> getGraphDataReversed(String hostName) =>
      UnmodifiableListView(
          _initialLoading ? [] : _hosts[hostName]?.graphDataReversed ?? []);

  HostsModel() {
    unawaited(() async {
      var hosts = await DatabaseService().getHosts();
      for (var host in hosts) {
        addHost(host);
      }
      _initialLoading = false;
      notifyListeners();
    }.call());
  }

  (Ping, StreamSubscription<PingData>) _createPing(Host host, int interval) {
    var ping = Ping(host.hostname, count: null, interval: interval);
    var subscription = ping.stream.listen((event) {
      if (event.response == null) return;
      host.time.add(event.response!.time);
      if (host.time.length > pingHistoryMax) {
        host.time.removeAt(0);
      }
      notifyListeners();
    });
    return (ping, subscription);
  }

  set settings(Settings settings) {
    _settings = settings;
    _hosts.forEach((key, value) {
      unawaited(() async {
        if (value.ping != null) {
          await value.ping!.$2.cancel();
        }
        value.ping = _createPing(value, settings.interval);
      }.call());
    });

    notifyListeners();
  }

  void addHost(Host host) {
    host.ping = _createPing(host, settings.interval);
    _hosts[host.hostname] = host;
    notifyListeners();
  }
}
