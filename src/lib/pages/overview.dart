import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';

class HostCard extends StatelessWidget {
  const HostCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    var state = context.watch<GlobalState>();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // move to the left
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name),
          ),
          const Spacer(),
          Checkbox(
            value: state.hosts[name]?.$2.time != null,
            onChanged: null,
          ),
        ],
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
