import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';

class HostCard extends StatelessWidget {
  const HostCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GlobalState>();
    var ms = state.hosts[name]?.$2.time?.inMilliseconds;

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
            const Spacer(),
            Row(
              children: ms != null
                  ? [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('$ms ms'),
                      ),
                      const Icon(Icons.check, color: Colors.green),
                    ]
                  : [
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child:
                            Text('N/A', style: TextStyle(color: Colors.grey)),
                      ),
                      const Icon(Icons.close, color: Colors.red),
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
    var state = context.watch<GlobalState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          children: [
            Icon(Icons.search),
            Flexible(
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
            IconButton(icon: Icon(Icons.settings), onPressed: null),
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
