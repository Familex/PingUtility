import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hosts.dart';
import '../models/settings.dart';
import '../services/database.dart';
import '../utils/pu_widgets.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key, this.host});
  final Host? host; // null for new host

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final _formKey = GlobalKey<FormState>();
  late String _hostname;
  late String _displayName;
  late String _pingIntervalStr;
  bool? _hostnameTestResult;
  (Ping, StreamSubscription<PingData>)? _hostnameTestPing;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.host != null;
    if (isEditing) {
      _hostname = widget.host!.hostname;
      _displayName = widget.host!.displayName ?? '';
      _pingIntervalStr = widget.host!.pingInterval?.toString() ?? '';
    } else {
      _hostname = '';
      _displayName = '';
      _pingIntervalStr = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
            isEditing ? "Edit host - ${widget.host!.hostname}" : "New host"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete host"),
                    content: Text(
                        "Are you sure you want to delete host ${widget.host!.hostname}?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text("Delete"),
                        onPressed: () {
                          context.read<HostsModel>().deleteHost(widget.host!);
                          unawaited(() async {
                            var result = await DatabaseService()
                                .deleteHost(widget.host!);
                            if (!result && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Error occurred while deleting host"),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }());
                          Navigator.of(context).pop(); // Pop dialog
                          Navigator.of(context).pop(); // Pop page
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                var pingInterval = int.tryParse(_pingIntervalStr);
                if (pingInterval == 0) pingInterval = null;
                var host = Host(
                  hostname: _hostname.trim(),
                  displayName:
                      _displayName.trim().isEmpty ? null : _displayName.trim(),
                  pingInterval: pingInterval,
                );
                if (isEditing) {
                  context
                      .read<HostsModel>()
                      .editHost(widget.host!.hostname, host);
                  unawaited(() async {
                    var result = await DatabaseService()
                        .editHost(widget.host!.hostname, host);
                    if (!result && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to update host"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }());
                } else {
                  context.read<HostsModel>().addHost(host);
                  unawaited(() async {
                    var result = await DatabaseService().addHost(host);
                    if (!result && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to add host"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }());
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: puTextFormField(
                      context: context,
                      labelText: 'Hostname',
                      initialValue: _hostname,
                      onSaved: (value) => _hostname = value!.trim(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  puButton(
                    context: context,
                    onPressed: _startHostnameTest,
                    color: _hostnameTestResult == null
                        ? null
                        : _hostnameTestResult!
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    textColor:
                        _hostnameTestResult == null ? null : Colors.black,
                    child: _hostnameTestResult == null
                        ? const Text('Test')
                        : Text(_hostnameTestResult! ? 'Online' : 'Offline'),
                  )
                ],
              ),
              const SizedBox(height: 10),
              puTextFormField(
                context: context,
                labelText: 'Display name',
                initialValue: _displayName,
                onSaved: (value) => _displayName = value?.trim() ?? '',
              ),
              const SizedBox(height: 10),
              Consumer<Settings>(
                builder: (context, settings, __) => puTextFormField(
                  context: context,
                  initialValue: _pingIntervalStr,
                  onSaved: (value) => _pingIntervalStr = value?.trim() ?? '',
                  validator: (value) {
                    value = value?.trim();
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Enter number';
                    }
                    return null;
                  },
                  labelText: 'Custom ping interval (seconds)',
                  hintText: settings.interval.toString(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _startHostnameTest() async {
    _formKey.currentState?.save();
    _hostnameTestResult = null;
    if (_hostnameTestPing != null) {
      _hostnameTestPing!.$2.cancel();
      _hostnameTestPing = null;
    }

    var ping = Ping(_hostname, count: 1, timeout: 1);
    var subscription = ping.stream.listen((event) {
      setState(() {
        if (event.summary == null) {
          _hostnameTestResult = event.response != null;
        } else {
          _hostnameTestResult = (event.summary!.received > 0);
        }
      });
    });
    _hostnameTestPing = (ping, subscription);
  }
}
