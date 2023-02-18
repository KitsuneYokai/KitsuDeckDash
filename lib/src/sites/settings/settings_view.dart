import 'package:flutter/material.dart';
import '../ui.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
          child: Expanded(
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
              //create a button to test the tray icon
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebsocketView()));
                  },
                  child: const Text("Open Websocket viewer")),
            ],
          )),
        ));
  }
}

// websocket viewer
class WebsocketView extends StatelessWidget {
  WebsocketView({
    super.key,
  });

  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.178.23/ws'),
  );
  static const routeName = '/websocket';
  @override
  Widget build(BuildContext context) {
    return MainView(
        title: "KitsuDeck websocket Viewer",
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Expanded(
              child: Column(
            children: [
              const Text("Websocket Viewer"),
              //create a button to test the tray icon
              StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  return Text(snapshot.hasData ? '${snapshot.data}' : '');
                },
              )
            ],
          )),
        ));
  }
}
