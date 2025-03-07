import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

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
        title: const Text("Settings"),
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
            Row(
              children: [
                Checkbox(
                    value: settings.customThemeColor != null,
                    onChanged: (value) {
                      settings.customThemeColor =
                          value ?? false ? Colors.deepPurple : null;
                    }),
                Text(
                  'Use custom theme color',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                FilledButton(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: settings.customThemeColor ?? Colors.deepPurple,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Pick a color'),
                        content: SingleChildScrollView(
                          child: HueRingPicker(
                            pickerColor:
                                settings.customThemeColor ?? Colors.deepPurple,
                            onColorChanged: (color) {
                              settings.customThemeColor = color;
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
