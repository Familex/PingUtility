import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'global_state.dart';
import 'pages/overview.dart';

void main() {
  runApp(const MainWindow());
}

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MaterialApp(
        title: 'Ping Utility',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const OverviewPage(),
      ),
    );
  }
}
