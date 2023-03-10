import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/sites/settings/settings_controller.dart';
import 'src/sites/settings/settings_service.dart';
import 'src/helper/settingsStorage.dart';
import 'src/helper/websocket/ws.dart';

String getTrayImagePath(String imageName) {
  return Platform.isWindows
      ? 'assets/images/$imageName.ico'
      : 'assets/images/$imageName.png';
}

String getImagePath(String imageName) {
  return Platform.isWindows
      ? 'assets/images/$imageName.bmp'
      : 'assets/images/$imageName.png';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the system tray
  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();
  final Menu menuMain = Menu();

  Future<void> initSystemTray() async {
    // We first init the systray menu and then add the menu entries
    await systemTray.initSystemTray(iconPath: getTrayImagePath('app_icon'));
    systemTray.setTitle("DeckDash");
    systemTray.setToolTip("Dashboard for the KitsuDeck");

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });

    await menuMain.buildFrom(
      [
        MenuItemLabel(
            label: 'Open',
            onClicked: (menuItem) async {
              var isTaskbar = await windowManager.isSkipTaskbar();
              if (isTaskbar) {
                await windowManager.setSkipTaskbar(false);
              }
              await windowManager.show();
              await windowManager.focus();
            }),
        MenuItemLabel(
            label: 'Hide',
            onClicked: (menuItem) async {
              await windowManager.setSkipTaskbar(true);
              await windowManager.hide();
            }),
        MenuSeparator(),
        MenuItemLabel(
            label: 'Quit',
            onClicked: (menuItem) async {
              await windowManager.close();
            }),
      ],
    );
    systemTray.setContextMenu(menuMain);
  }

  await initSystemTray();

  // check if there is a KitsuDeck saved in the shared preferences
  SharedPref sharedPref = SharedPref();
  var kitsuDeck = await sharedPref.read("kitsuDeck");
  if (kitsuDeck == null) {
  } else {
    // connect to the websocket
    final webSocketUrl = "ws://${jsonDecode(kitsuDeck)["hostname"]}/ws";
    WebSocketService webSocketService = WebSocketService(webSocketUrl);
    await webSocketService.connect();
  }

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
  // windowManager code
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: 'DeckDash',
    size: Size(800, 600),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });
}
