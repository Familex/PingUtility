import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_utility/utils/non_empty_formatter.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<Settings>();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Settings"),
        ),
        body: Column(
          children: [
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  controller: TextEditingController(
                    text: settings.interval.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    NonEmptyFormatter(),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Ping interval (seconds)',
                  ),
                  onChanged: (value) {
                    var val = int.tryParse(value);
                    if (val == null) return;
                    settings.interval = val;
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
