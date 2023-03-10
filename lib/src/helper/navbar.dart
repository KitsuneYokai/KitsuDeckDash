import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../sites/home/home.dart';
import '../sites/KitsuDeck/KitsuDeck.dart';
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

double width = 230;
bool closed = false;

class NavbarFinal extends State<_Navbar> {
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
              Theme.of(context).primaryColor.withOpacity(0.9),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
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
                    width = width == 60 ? 230 : 60;
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
                    width = width == 60 ? 230 : 60;
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
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const Home()),
                          (Route<dynamic> route) => false);
                    },
                    leading: const Icon(Icons.home, color: Colors.white),
                    //add a hover color to the list tile
                    hoverColor: Theme.of(context).splashColor,
                  ),
                  ListTile(
                    title: const Text(
                      "KitsuDeck",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const KitsuDeck()),
                          (Route<dynamic> route) => false);
                    },
                    // add a icon to the list tile
                    leading: const Icon(Icons.devices, color: Colors.white),
                    hoverColor: Theme.of(context).splashColor,
                  ),
                ] else ...[
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const Home()),
                          (Route<dynamic> route) => false);
                    },
                    leading: const Icon(Icons.home, color: Colors.white),
                    //add a hover color to the list tile
                    hoverColor: Theme.of(context).splashColor,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const KitsuDeck()),
                          (Route<dynamic> route) => false);
                    },
                    leading: const Icon(Icons.devices, color: Colors.white),
                    hoverColor: Theme.of(context).splashColor,
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
