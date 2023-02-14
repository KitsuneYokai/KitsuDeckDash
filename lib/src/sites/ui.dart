import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

import '../sites/home/home.dart';
import '../helper/navbar.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatefulWidget {
  static const routeName = '/';

  SampleItemListView({Key? key}) : super(key: key);

  @override
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView>
    with WindowListener {
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
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes'),
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
        body: Row(
          children: const [
            Navbar(),
            Home(),
          ],
        ),
      ),
    );
  }
}
