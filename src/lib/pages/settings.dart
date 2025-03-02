import 'package:flutter/material.dart';

class Settings extends ChangeNotifier {
  int interval = 1000;

  void setInterval(int value) {
    interval = value;
    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     title: const Text("Settings"),
    //   ),
    //   body: FutureBuilder(
    //     future: SharedPreferences.getInstance(),
    //     builder:
    //         (BuildContext context, AsyncSnapshot<SharedPreferences> prefs) {
    //       if (!prefs.hasData) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //       if (prefs.hasError) {
    //         return Column(
    //           children: [
    //             Text("${prefs.error}"),
    //             Icon(Icons.error),
    //           ],
    //         );
    //       }
    //       return Column(children: [
    //         Flexible(
    //           child: Padding(
    //             padding:
    //                 const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
    //             child: TextFormField(
    //               initialValue: prefs.data?.getString("interval") ?? "1000",
    //               decoration: const InputDecoration(
    //                 border: UnderlineInputBorder(),
    //                 labelText: 'Ping interval (ms)',
    //               ),
    //             ),
    //           ),
    //         ),
    //       ]);
    //     },
    //   ),
    // );
  }
}
