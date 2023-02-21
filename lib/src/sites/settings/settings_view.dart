import 'package:flutter/material.dart';
import '../ui.dart';
import '../../helper/settingsStorage.dart';
import '../../helper/settingsStorage.dart';
import '../../helper/websocket/ws.dart';
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
                  child: const Text("print: get_shared_preferences")),
              ElevatedButton(
                  onPressed: () async {
                    SharedPref sharedPref = SharedPref();
                    await sharedPref.remove("kitsuDeck");
                  },
                  child: const Text("print: remove_shared_preferences")),
              ElevatedButton(
                  onPressed: () async {
                    WebSocketService webSocketService = WebSocketService("");
                    var isConnected = webSocketService.isWebSocketConnected();
                    print(isConnected);
                  },
                  child: const Text("print: websocket_is_connected")),
            ],
          ),
        ));
  }
}
