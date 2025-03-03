import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/hosts.dart';
import 'models/settings.dart';
import 'pages/overview.dart';
import 'services/database.dart';

// XXX will be overwritten in main function
Settings settings = Settings(interval: -1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  settings = await DatabaseService().getSettings();
  runApp(const MainWindow());
}

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settings),
        ChangeNotifierProxyProvider<Settings, HostsModel>(
          create: (_) => HostsModel(),
          update: (_, settings, hosts) {
            if (hosts == null) {
              throw ArgumentError.notNull('hosts');
            }
            hosts.settings = settings;
            return hosts;
          },
        )
      ],
      child: MaterialApp(
        title: 'Ping Utility',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: OverviewPage(),
      ),
    );
  }
}
