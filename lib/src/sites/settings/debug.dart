import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kitsu_deck_dash/src/classes/kitsu_deck/device.dart';
import 'package:provider/provider.dart';

import '../../classes/websocket/connector.dart';
import '../../helper/settingsStorage.dart';
import 'auth_device.dart';

class DebugSettings extends StatefulWidget {
  const DebugSettings({
    Key? key,
  }) : super(key: key);

  @override
  DebugSettingsState createState() => DebugSettingsState();
}

class DebugSettingsState extends State<DebugSettings> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sharedPref = SharedPref();
    final kitsuDeck = Provider.of<KitsuDeck>(context, listen: false);
    final websocket = Provider.of<DeckWebsocket>(context, listen: false);

    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
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
                            .withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      TextButton(
                        child: Text("Reauth KitsuDeck"),
                        onPressed: () {
                          showAuthenticateKitsuDeck(context);
                        },
                      ),
                      // load image bin file from downloads folder
                    ],
                  ))),
        )
      ],
    ));
  }
}
