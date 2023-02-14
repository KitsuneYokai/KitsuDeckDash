import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../sites/settings/settings_view.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return _Navbar();
  }
}

class _Navbar extends StatefulWidget {
  @override
  NavbarFinal createState() => NavbarFinal();
}

class NavbarFinal extends State<_Navbar> {
  double width = 200;
  bool closed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        // add a gradient background to the sidebar from top left to bottom right
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              //set the height of the window buttons
              height: 40,
              child:
                  DragToMoveArea(child: Container(color: Colors.transparent)),
            ),
            if (closed == false) ...[
              ListTile(
                title: const Text(
                  "KitsuDeckDash",
                  style: TextStyle(color: Colors.white),
                ),
                leading: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onTap: () {
                  setState(() {
                    closed = !closed;
                  });
                  setState(() {
                    width = width == 60 ? 200 : 60;
                  });
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onTap: () {
                  setState(() {
                    closed = !closed;
                  });
                  setState(() {
                    width = width == 60 ? 200 : 60;
                  });
                },
              ),
            ],
            Expanded(
                child: ListView(
              children: [
                if (closed == false) ...[
                  ListTile(
                    title: const Text(
                      "Home",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {},
                    leading: const Icon(Icons.home, color: Colors.white),
                    //add a hover color to the list tile
                    hoverColor: Colors.white,
                  ),
                  ListTile(
                    title: const Text(
                      "Devices",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {},
                    // add a icon to the list tile
                    leading: const Icon(Icons.devices, color: Colors.white),
                  ),
                ] else ...[
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.home, color: Colors.white),
                    //add a hover color to the list tile
                    hoverColor: Colors.white,
                  ),
                  ListTile(
                    onTap: () {},
                    // add a icon to the list tile
                    leading: const Icon(Icons.devices, color: Colors.white),
                  ),
                ]
              ],
            )),
            if (closed == false) ...[
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                title: const Text(
                  "Settings",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(SettingsView.routeName);
                },
              )
            ] else ...[
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(SettingsView.routeName);
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
          height: 40,
          child: DragToMoveArea(child: Container(color: Colors.transparent)),
        )),
        IconButton(
            onPressed: () async {
              await windowManager.minimize();
            },
            icon: const Icon(Icons.close))
      ],
    );
  }
}
