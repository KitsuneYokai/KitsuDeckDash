import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../helper/navbar.dart';

/// Displays a list of SampleItems.
class MainView extends StatefulWidget {
  final Widget child;
  final String title;
  MainView({Key? key, required this.child, required this.title})
      : super(key: key);

  @override
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<MainView> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    _init();
    // Disable the default Mac OS buttons
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    await windowManager.show();
    await windowManager.focus();
    if (isPreventClose) {
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        body: Row(
          children: [
            const Navbar(),
            Expanded(
              // background color of the row
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DragToMoveArea(
                    child: SizedBox(
                      height: 40,
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(widget.title,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        //minimize button
                        IconButton(
                            onPressed: () async {
                              await windowManager.minimize();
                            },
                            icon: const Icon(Icons.minimize)),
                        //Maximize button
                        IconButton(
                            onPressed: () async {
                              // check if the window is maximized
                              bool isMaximized =
                                  await windowManager.isMaximized();
                              if (isMaximized) {
                                await windowManager.unmaximize();
                              } else {
                                // if the window is not maximized, maximize it
                                await windowManager.maximize();
                              }
                              setState(() {});
                            },
                            icon: const Icon(Icons.crop_square)),
                        //close button
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            // will just hide the program to the tray
                            await windowManager.hide();
                            await windowManager.setSkipTaskbar(true);
                          },
                        )
                      ]),
                    ),
                  ),
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: widget.child,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
