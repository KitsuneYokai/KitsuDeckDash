import 'package:flutter/material.dart';
import '../ui.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../helper/settingsStorage.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return MainView(
        title: "Settings",
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Glue the SettingsController to the theme selection DropdownButton.
          //
          // When a user selects a theme from the dropdown list, the
          // SettingsController is updated, which rebuilds the MaterialApp.

          child: Column(
            children: [
              const Text("Theme:"),
              DropdownButton<ThemeMode>(
                // Read the selected themeMode from the controller
                value: controller.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: controller.updateThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Theme'),
                  )
                ],
              ),
              const Text("Debug Stuff:"),

              ElevatedButton(
                  onPressed: () async {
                    SharedPref sharedPref = SharedPref();
                    print(await sharedPref.read("kitsuDeck"));
                  },
                  child: const Text("get_shared_preferences")),
              //create a button to test the tray icon
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WebsocketView()));
                  },
                  child: const Text("Open Websocket viewer")),
            ],
          ),
        ));
  }
}

// websocket viewer
class WebsocketView extends StatefulWidget {
  const WebsocketView({key}) : super(key: key);

  static const routeName = '/websocket';

  @override
  _WebsocketViewState createState() => _WebsocketViewState();
}

class _WebsocketViewState extends State<WebsocketView> {
  final TextEditingController _controller = TextEditingController();
  final channel = WebSocketChannel.connect(Uri.parse('ws://192.168.178.23/ws'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Websocket Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data);
                  } else {
                    return const Text('Connecting...');
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Enter message'),
                    onSubmitted: (text) {
                      channel.sink.add(text);
                      _controller.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    channel.sink.add(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
