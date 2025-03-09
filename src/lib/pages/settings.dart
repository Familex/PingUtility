import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/settings.dart';
import '../utils/non_empty_formatter.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  // FIXME is it ok?
  final TextEditingController _intervalTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<Settings>();
    _intervalTEC.text = settings.interval.toString();

    void updateInterval() {
      var val = int.tryParse(_intervalTEC.text);
      if (val == null) return;
      settings.interval = val;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Text('Settings'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => FutureBuilder(
                  future: buildInfoPopup(context),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return alertDialogWrapper(
                        const Text('Loading...'),
                        const Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return alertDialogWrapper(
                        const Text('Error'),
                        Text(snapshot.error.toString()),
                      );
                    }
                    return snapshot.data!;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            TextField(
              controller: _intervalTEC,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                NonEmptyFormatter(),
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Ping interval (seconds)',
              ),
              onChanged: (_) => updateInterval(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: settings.themeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(
                    'Use system theme',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(
                    'Light theme',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(
                    'Dark theme',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<Settings>().themeMode = value;
                }
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Theme Mode',
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  const Text('Use custom theme color'),
                  const Spacer(),
                  RawMaterialButton(
                    fillColor: settings.customThemeColor ?? Colors.grey,
                    shape: const CircleBorder(),
                    onPressed: settings.customThemeColor == null
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Pick a color'),
                                content: SingleChildScrollView(
                                  child: MaterialPicker(
                                    pickerColor: settings.customThemeColor ??
                                        Colors.deepPurple,
                                    enableLabel: true,
                                    portraitOnly: true,
                                    onColorChanged: (color) {
                                      settings.customThemeColor = color;
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                  )
                ],
              ),
              value: settings.customThemeColor != null,
              onChanged: (value) {
                settings.customThemeColor =
                    value ?? false ? Colors.deepPurple : null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<Widget> buildInfoPopup(BuildContext context) async {
  var packageInfo = await PackageInfo.fromPlatform();
  var installationDatePretty = packageInfo.installTime == null
      ? null
      : Jiffy.parseFromDateTime(packageInfo.installTime!).yMMMEdjm;
  var fromLastUpdatePretty = packageInfo.updateTime == null
      ? null
      : Jiffy.parseFromDateTime(packageInfo.updateTime!).from(Jiffy.now());

  return alertDialogWrapper(
    Text('${packageInfo.appName} v${packageInfo.version}'),
    Column(
      children: [
        const ListTile(
          title: Text(
              'Flutter application for ping monitoring. It is open source and can be found on GitHub.'),
        ),
        ListTile(
          leading: const Icon(Icons.link_outlined),
          title: const Text('Source code'),
          onTap: () => launchUrl(
            Uri.parse('https://github.com/Familex/PingUtility'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.report_problem_outlined),
          title: const Text('Leave feedback (issue)'),
          onTap: () => launchUrl(
            Uri.parse('https://github.com/Familex/PingUtility/issues'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Licenses'),
          onTap: () => showLicensePage(
            context: context,
            applicationName: packageInfo.appName,
            applicationVersion: packageInfo.version,
            // FIXME put applicationIcon here
          ),
        ),
        if (packageInfo.installerStore != null)
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('Installation method'),
            subtitle: Text(packageInfo.installerStore!),
          ),
        if (installationDatePretty != null && fromLastUpdatePretty != null)
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('From last update'),
            subtitle: Text(fromLastUpdatePretty),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('installed on $installationDatePretty'),
              ),
            ),
          )
      ],
    ),
  );
}

Widget alertDialogWrapper(Widget title, Widget content) {
  return AlertDialog(
    title: title,
    content: SingleChildScrollView(child: content),
  );
}
