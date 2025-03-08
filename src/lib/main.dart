import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/hosts.dart';
import 'models/settings.dart';
import 'pages/overview.dart';
import 'services/database.dart';

// XXX will be overwritten in main function
Settings settings = Settings(interval: -1, themeMode: -1, customColor: null);

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
        builder: (lightDynamic, darkDynamic) => Consumer<Settings>(
          builder: (_, settings, __) {
            return MaterialApp(
              title: 'Ping Utility',
              themeMode: settings.themeMode,
              theme: getLightColorScheme(settings, lightDynamic),
              darkTheme: getDarkColorScheme(settings, darkDynamic),
              home: const OverviewPage(),
            );
          },
        ),
      ),
    );
  }
}

ThemeData getLightColorScheme(Settings settings, ColorScheme? lightDynamic) {
  if (settings.customThemeColor != null) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: settings.customThemeColor!,
        brightness: Brightness.light,
      ),
    );
  }
  return ThemeData(
    useMaterial3: true,
    colorScheme:
        lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  );
}

ThemeData getDarkColorScheme(Settings settings, ColorScheme? darkDynamic) {
  if (settings.customThemeColor != null) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: settings.customThemeColor!,
        brightness: Brightness.dark,
      ),
    );
  }
  return ThemeData(
    useMaterial3: true,
    colorScheme:
        darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  );
}
