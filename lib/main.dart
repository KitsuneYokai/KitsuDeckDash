import 'dart:async';
import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/sites/settings/settings_controller.dart';
import 'src/sites/settings/settings_service.dart';

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
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();
  final Menu _menuMain = Menu();
  final Menu _menuSimple = Menu();

  Future<void> initSystemTray() async {
    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(iconPath: getTrayImagePath('app_icon'));
    _systemTray.setTitle("DeckDash");
    _systemTray.setToolTip("Dashboard for the KitsuDeck");

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? _appWindow.show() : _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _appWindow.show();
      }
    });

    await _menuMain.buildFrom(
      [
        MenuItemLabel(
            label: 'Open',
            onClicked: (menuItem) {
              windowManager.show();
              windowManager.focus();
            }),
        MenuItemLabel(
            label: 'Hide',
            onClicked: (menuItem) {
              windowManager.minimize();
            }),
        MenuSeparator(),
        MenuItemLabel(
            label: 'Quit',
            onClicked: (menuItem) {
              windowManager.close();
            }),
      ],
    );
    _systemTray.setContextMenu(_menuMain);
  }

  await initSystemTray();

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
    minimumSize: Size(480, 320),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });
}
