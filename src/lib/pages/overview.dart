import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ping_utility/pages/settings.dart';
import 'package:provider/provider.dart';

import '../models/hosts.dart';

class HostCard extends StatelessWidget {
  const HostCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    var state = context.watch<HostsModel>();
    var (min, avg, max) = () {
      var data = state
          .getGraphDataReversed(name)
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // move to the left
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
                child: ClipRect(
                    child: LineChart(LineChartData(
              lineTouchData: LineTouchData(enabled: false),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  spots: () {
                    List<FlSpot> result = [];
                    var ind = smallGraphElements;
                    for (var val in state.getGraphDataReversed(name)) {
                      if (val == null) continue;
                      result.add(FlSpot(
                          (--ind).toDouble(), val.inMilliseconds.toDouble()));
                    }
                    return result;
                  }(),
                ),
              ],
            )))),
            Row(
              children: [
                const Spacer(),
                (avg != null && min != null && max != null
                    ? Text(
                        '${min.toStringAsFixed(2)}/${avg.toStringAsFixed(2)}/${max.toStringAsFixed(2)} ms')
                    : Text('N/A', style: TextStyle(color: Colors.grey))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<HostsModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Icon(Icons.search),
            const Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
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
      body: GridView.count(
        crossAxisCount: 2,
        children: state.hosts.keys.map((name) => HostCard(name: name)).toList(),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      ),
    );
  }
}
