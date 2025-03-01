import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/widgets.dart';

const timeoutMs = 3000;
const pingHistoryMax = 100;
const smallGraphElements = 20;

// store host ip or dns name
final class Host {
  Host(this.name);

  final String name;
  List<Duration?> time = [];
}

final class GlobalState extends ChangeNotifier {
  GlobalState() {
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

  final Map<String, (Ping, Host)> hosts = {};

  Iterable<Duration?> getGraphDataReversed(String hostName) =>
      hosts[hostName]?.$2.time.reversed.take(smallGraphElements) ?? [];

  void addHost(Host host) {
    var ping = Ping(host.name, count: null, interval: 1);
    hosts[host.name] = (ping, host);
    ping.stream.listen((event) {
      if (event.response != null) {
        host.time.add(event.response!.time);
        if (host.time.length > pingHistoryMax) {
          host.time.removeAt(0);
        }
        notifyListeners();
      }
    });
    notifyListeners();
  }
}
