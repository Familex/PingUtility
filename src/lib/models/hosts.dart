import 'dart:async';
import 'dart:collection';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';
import 'settings.dart';

const pingHistoryMax = 30;

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
  Queue<(Ping, StreamSubscription<PingData>)> oneTimePing = Queue.from([]);
}

final class HostsModel extends ChangeNotifier {
  final Map<String, Host> _hosts = {};
  late Settings _settings;
  bool _initialLoading = true;

  bool get isInitialLoading => _initialLoading;
  Settings get settings => _settings;
  UnmodifiableMapView<String, Host> get hosts =>
      UnmodifiableMapView(_initialLoading ? {} : _hosts);
  UnmodifiableListView<Duration?> getGraphDataReversed(String hostName) =>
      UnmodifiableListView(_initialLoading
          ? []
          : _hosts[hostName]?.time.reversed.take(pingHistoryMax) ?? []);

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

  (Ping, StreamSubscription<PingData>)? _createPing(Host host, int? count) {
    assert(count == null || count == 1);
    var interval = count != null ? 1 : host.pingInterval ?? settings.interval;
    if (interval <= 0) return null;

    var ping = Ping(host.hostname,
        count: count, interval: interval, timeout: settings.pingTimeout);
    var subscription = ping.stream.listen((event) {
      // add to history
      if (event.response != null) {
        host.time.add(event.response!.time);
        if (host.time.length > pingHistoryMax) {
          host.time.removeAt(0);
        }
        notifyListeners();
      }
      // remove from oneTimePing queue
      if (count != null) {
        assert(host.oneTimePing.isNotEmpty);
        host.oneTimePing.removeFirst().$2.cancel();
      }
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
        value.ping = _createPing(value, null);
      }.call());
    });

    notifyListeners();
  }

  void addHost(Host host) {
    host.ping = _createPing(host, null);
    _hosts[host.hostname] = host;
    notifyListeners();
  }

  Future startOneTimePing(String hostname) async {
    if (_hosts[hostname] == null) return;
    var ping = _createPing(_hosts[hostname]!, 1);
    if (ping != null) {
      _hosts[hostname]!.oneTimePing.add(ping);
    }
  }

  void editHost(String oldHostname, Host host) {
    unawaited(() async {
      if (_hosts[oldHostname]?.ping != null) {
        await _hosts[oldHostname]?.ping!.$2.cancel();
      }
      host.ping = _createPing(host, null);
    }.call());
    _hosts.remove(oldHostname);
    _hosts[host.hostname] = host;
    notifyListeners();
  }

  void deleteHost(Host host) {
    if (host.ping != null) {
      host.ping!.$2.cancel();
    }
    _hosts.remove(host.hostname);
    notifyListeners();
  }
}
