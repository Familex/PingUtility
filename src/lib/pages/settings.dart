import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/settings.dart';
import '../utils/pu_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // FIXME is it ok?
  final TextEditingController _intervalTEC = TextEditingController();
  final TextEditingController _pingTimeoutTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<Settings>();
    // FIXME is it ok?
    _intervalTEC.text = settings.interval.toString();
    _pingTimeoutTEC.text = settings.pingTimeout.toString();

    void updateInterval() {
      var val = int.tryParse(_intervalTEC.text);
      if (val == null || val <= 0) return;
      settings.interval = val;
    }

    void updatePingTimeout() {
      var val = int.tryParse(_pingTimeoutTEC.text);
      if (val == null || val <= 0) return;
      settings.pingTimeout = val;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Text('Settings'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info_outline),
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
            puTextField(
              context: context,
              labelText: 'Ping interval (seconds)',
              controller: _intervalTEC,
              onChanged: (_) => updateInterval(),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            puTextField(
              context: context,
              labelText: 'Ping timeout (seconds)',
              controller: _pingTimeoutTEC,
              onChanged: (_) => updatePingTimeout(),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            puDropdownButtonFormField(
              context: context,
              value: settings.themeMode,
              labelText: 'Theme Mode',
              onChanged: (value) {
                if (value != null) {
                  context.read<Settings>().themeMode = value;
                }
              },
              items: [
                const DropdownMenuItem(
                  value: ThemeMode.system,
                  child: PuText('Use system theme'),
                ),
                const DropdownMenuItem(
                  value: ThemeMode.light,
                  child: PuText('Light theme'),
                ),
                const DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: PuText('Dark theme'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PuLabeledCheckbox(
              value: settings.customThemeColor != null,
              onChanged: (value) {
                settings.customThemeColor =
                    value ?? false ? Colors.deepPurple : null;
              },
              title: Row(
                children: [
                  const PuText('Use custom theme color'),
                  const Spacer(),
                  RawMaterialButton(
                    fillColor:
                        settings.customThemeColor ?? Colors.grey.shade300,
                    shape: const CircleBorder(),
                    constraints:
                        const BoxConstraints(minWidth: 60.0, minHeight: 36.0),
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
