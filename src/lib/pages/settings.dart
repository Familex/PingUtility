import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_utility/services/database.dart';
import 'package:ping_utility/utils/non_empty_formatter.dart';

import '../structs/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _intervalController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  Settings? _savedState;

  @override
  void initState() {
    super.initState();
    unawaited(() async {
      await _loadSavedState();
      _intervalController.text = _savedState!.interval.toString();
    }());
  }

  Future _loadSavedState() async {
    var settings = await _databaseService.getSettings();
    setState(() {
      _savedState = settings;
    });
  }

  Future _onSave() async {
    var interval = int.tryParse(_intervalController.text);
    if (interval != null) {
      await _databaseService.setInterval(interval);
    }
    _loadSavedState();
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    NonEmptyFormatter(),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Ping interval (ms)',
                  ),
                  onChanged: (_) => _onSave(),
                ),
              ),
            ),
          ],
        ));
  }
}
