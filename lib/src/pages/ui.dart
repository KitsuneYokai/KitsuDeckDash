import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import './kitsu_deck/index.dart';
import 'settings/index.dart';

class MainView extends StatefulWidget {
  const MainView({
    Key? key,
  }) : super(key: key);

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> with WindowListener {
  int _selectedIndex = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    windowManager.addListener(this);
    init();
    // Disable the default Mac OS buttons
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    await windowManager.show();
    await windowManager.focus();

    if (isPreventClose) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close the Dashboard?'),
            content: const Text(
                'This will close the app, and the connection to the KitsuDeck will be lost.\n\nIf you want to close the Dashboard, but keep the connection to the KitsuDeck, please use the "Minimize" button instead.'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      child: Scaffold(
          body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              // add gradient from top left top bottom right
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.6),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
            ),
            height: 25,
            child: Row(
              children: [
                TextButton(
                    child: _isExpanded
                        ? const Icon(Icons.menu_open)
                        : const Icon(Icons.menu),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    }),
                const Expanded(
                  child: DragToMoveArea(
                      child: SizedBox(
                    width: double.infinity,
                    height: 25,
                  )),
                ),
                Row(children: [
                  TextButton(
                      onPressed: () async {
                        await windowManager.minimize();
                      },
                      child: const Icon(Icons.minimize)),
                  //Maximize button
                  TextButton(
                      onPressed: () async {
                        // check if the window is maximized
                        bool isMaximized = await windowManager.isMaximized();
                        if (isMaximized) {
                          await windowManager.unmaximize();
                        } else {
                          // if the window is not maximized, maximize it
                          await windowManager.maximize();
                        }
                        setState(() {});
                      },
                      child: const Icon(Icons.crop_square)),
                  //close button
                  TextButton(
                    child: const Icon(Icons.close, color: Colors.white),
                    onPressed: () async {
                      // will just hide the program to the tray
                      await windowManager.hide();
                      await windowManager.setSkipTaskbar(true);
                    },
                  )
                ])
              ],
            ),
          ),
          Expanded(
              child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        // add gradient from top left top bottom right
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.6),
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: NavigationRail(
                        minExtendedWidth: 200,
                        backgroundColor: Colors.transparent,
                        extended: _isExpanded,
                        selectedIndex: _selectedIndex,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.keyboard_outlined),
                            selectedIcon: Icon(Icons.keyboard),
                            label: Text('KitsuDeck'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings_outlined),
                            selectedIcon: Icon(Icons.settings),
                            label: Text('Settings'),
                          ),
                        ],
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                    ),
                    // background color of the row
                    if (_selectedIndex == 0)
                      const KitsuDeckDashboard()
                    else if (_selectedIndex == 1)
                      const SettingsNavbar(),
                  ],
                ),
              )
            ],
          ))
        ],
      )),
    );
  }
}
