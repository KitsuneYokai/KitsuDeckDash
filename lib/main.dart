import 'dart:async';
import 'dart:io';

import 'package:kitsu_deck_dash/src/classes/kitsu_deck/device.dart';
import 'package:kitsu_deck_dash/src/classes/websocket/connector.dart';
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
    systemTray.setToolTip("KitsuDeckDash");

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

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DeckWebsocket>(
        create: (context) => DeckWebsocket(),
      ),
      ChangeNotifierProvider<KitsuDeck>(create: (context) => KitsuDeck())
    ],
    child: const KitsuDeckDash(),
  ));
}
