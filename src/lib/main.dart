import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/hosts.dart';
import 'models/settings.dart';
import 'pages/overview.dart';
import 'services/database.dart';

// XXX will be overwritten in main function
Settings settings =
    Settings(interval: -1, themeMode: -1, themeColor: Color(-1));

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
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => MaterialApp(
          title: 'Ping Utility',
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic ??
                ColorScheme.fromSeed(
                  seedColor: settings.themeColor,
                ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: settings.themeColor,
                  brightness: Brightness.dark,
                ),
          ),
          home: OverviewPage(),
        ),
      ),
    );
  }
}
