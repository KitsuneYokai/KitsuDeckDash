import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/websocket/connector.dart';
import '../../helper/settingsStorage.dart';
import 'app.dart';
import 'debug.dart';
import 'kitsu_deck.dart';

class SettingsNavbar extends StatefulWidget {
  const SettingsNavbar({
    Key? key,
  }) : super(key: key);

  @override
  SettingsNavbarState createState() => SettingsNavbarState();
}

class SettingsNavbarState extends State<SettingsNavbar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sharedPref = SharedPref();
    final websocket = Provider.of<DeckWebsocket>(context, listen: false);

    return Expanded(
        child: Row(
      children: [
        Container(
          width: 250,
          decoration: BoxDecoration(
            // add gradient from top left top bottomright
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.5),
                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.4),
                ),
                child: ListView(children: [
                  ListTile(
                    title: Row(children: const [
                      Icon(Icons.keyboard_outlined),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text("KitsuDeck"),
                      ),
                    ]),
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  ListTile(
                    title: Row(children: const [
                      Icon(Icons.app_registration),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text("App Settings"),
                      ),
                    ]),
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  ListTile(
                    title: Row(children: const [
                      Icon(Icons.developer_board_rounded),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text("Debug"),
                      ),
                    ]),
                    onTap: () {
                      setState(() {
                        selectedIndex = 999;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                ]),
              )),
        ),
        if (selectedIndex == 0)
          const KitsuDeckSettings()
        else if (selectedIndex == 1)
          const AppSettings()
        else if (selectedIndex == 999)
          const DebugSettings(),
      ],
    ));
  }
}
