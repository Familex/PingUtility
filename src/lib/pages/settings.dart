import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_utility/utils/non_empty_formatter.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  // FIXME is it ok?
  final TextEditingController _intervalTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<Settings>();
    _intervalTEC.text = settings.interval.toString();

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
                  onTapOutside: (_) {
                    var val = int.tryParse(_intervalTEC.text);
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
