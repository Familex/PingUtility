import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:provider/provider.dart';

import '../models/hosts.dart';
import '../models/settings.dart';
import './host.dart';
import './settings.dart';

class HostCard extends StatelessWidget {
  const HostCard({super.key, required this.host});

  final Host host;

  @override
  Widget build(BuildContext context) {
    var (min, avg, max) = () {
      var data = host.graphDataReversed
          .where((el) => el != null)
          .map((el) => el!.inMilliseconds.toDouble());
      if (data.isEmpty) return (null, null, null);
      double total = 0.0;
      double min = double.infinity;
      double max = -double.infinity;
      for (var el in data) {
        if (el < min) min = el;
        if (el > max) max = el;
        total += el;
      }
      return (min, total / data.length, max);
    }();

    return HoldTimeoutDetector(
      onTimerInitiated: () {},
      onTimeout: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HostPage(host: host)),
      ),
      onTap: () => context.read<HostsModel>().startOneTimePing(host.hostname),
      holdTimeout: const Duration(milliseconds: 150),
      enableHapticFeedback: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // move to the left
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    host.displayName ?? host.hostname,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Consumer<Settings>(
                    builder: (_, settings, __) => Text(
                          "${host.pingInterval?.toString() ?? settings.interval}s",
                        )),
              ]),
              Expanded(
                  child: ClipRect(
                      child: LineChart(LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                    color: Theme.of(context).colorScheme.primary,
                    spots: () {
                      List<FlSpot> result = [];
                      var ind = smallGraphElements;
                      for (var val in host.graphDataReversed) {
                        if (val == null) continue;
                        result.add(FlSpot(
                            (--ind).toDouble(), val.inMilliseconds.toDouble()));
                      }
                      return result;
                    }(),
                  ),
                ],
              )))),
              // Row > Expanded > Text needed for right alignment with overflow
              Row(
                children: [
                  Expanded(
                    child: (avg != null && min != null && max != null
                        ? Text(
                            '${min.toStringAsFixed(2)}/${avg.toStringAsFixed(2)}/${max.toStringAsFixed(2)} ms',
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          )
                        : const Text(
                            'N/A',
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final TextEditingController _searchTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchTEC.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger rebuild to update filtered hosts
  }

  @override
  void dispose() {
    _searchTEC.removeListener(_onSearchChanged);
    _searchTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Icon(Icons.search),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchTEC,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search...',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<HostsModel>(builder: (context, state, __) {
        if (state.isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var allHostNames = state.hosts.keys.toList();
        var query = _searchTEC.text;
        var filteredHosts = query.isEmpty
            ? allHostNames
            : Fuzzy(allHostNames)
                .search(query)
                .map((r) => r.matches.firstOrNull)
                .where((el) => el != null)
                .map((el) => el!.value)
                .toList();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (_, index) =>
              HostCard(host: state.hosts[filteredHosts[index]]!),
          itemCount: filteredHosts.length,
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const HostPage(host: null)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
