import 'dart:async';
import 'dart:io';

import 'package:kitsu_deck_dash/src/classes/kitsu_deck/connector.dart';
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';

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

final kitsuDeck = DeckWebsocket();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the KitsuDeck class with the shared preferences settings
  await kitsuDeck.initKitsuDeckSettings();

  if (kitsuDeck.ip != null.toString()) {
    kitsuDeck.initConnection("ws://${kitsuDeck.ip}/ws", kitsuDeck.pin);
  }
  final version = await getVersion();
  kitsuDeck.log("KitsuDeckDash Version: ${version}");
  // initialize the system tray
  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();
  final Menu menuMain = Menu();

  Future<void> initSystemTray() async {
    // We first init the sys tray menu and then add the menu entries
    await systemTray.initSystemTray(iconPath: getTrayImagePath('app_icon'));
    systemTray.setTitle("DeckDash");
    systemTray.setToolTip("KitsuDeckDash");

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
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

  // windowManager code
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: 'DeckDash',
    size: Size(900, 600),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DeckWebsocket>(
        create: (context) => kitsuDeck,
      ),
    ],
    child: const KitsuDeckDash(),
  ));
}

getVersion() {
  final pubspecFile = File('pubspec.yaml');
  final lines = pubspecFile.readAsLinesSync();
  for (var line in lines) {
    if (line.contains('version')) {
      return line.split(':')[1].trim();
    }
  }
  return null;
}
