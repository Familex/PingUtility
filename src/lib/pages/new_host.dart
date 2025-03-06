import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hosts.dart';
import '../models/settings.dart';
import '../services/database.dart';

class NewHostPage extends StatefulWidget {
  const NewHostPage({super.key});

  @override
  State<NewHostPage> createState() => _NewHostPageState();
}

class _NewHostPageState extends State<NewHostPage> {
  final _formKey = GlobalKey<FormState>();

  // form fields
  String hostname = '';
  String? displayName;
  int? pingInterval;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Text("New host"),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  var host = Host(
                    hostname: hostname,
                    displayName: displayName,
                    pingInterval: pingInterval,
                  );
                  context.read<HostsModel>().addHost(host);
                  DatabaseService().addHost(host);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) => hostname = value!.trim(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required field';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Hostname',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                onSaved: (value) => displayName = value?.trim(),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Display name',
                ),
              ),
              SizedBox(height: 10),
              Consumer<Settings>(
                builder: (_, settings, __) => TextFormField(
                  onSaved: (value) =>
                      pingInterval = int.tryParse(value?.trim() ?? ''),
                  validator: (value) {
                    value = value?.trim();
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Enter number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Custom ping interval (seconds)',
                    hintText: settings.interval.toString(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
