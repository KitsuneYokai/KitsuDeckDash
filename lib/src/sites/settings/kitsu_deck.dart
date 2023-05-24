import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/kitsu_deck/device.dart';
import '../../classes/websocket/connector.dart';
import '../../helper/settingsStorage.dart';
import '../kitsu_deck/no_device.dart';

class KitsuDeckSettings extends StatefulWidget {
  const KitsuDeckSettings({
    Key? key,
  }) : super(key: key);

  @override
  KitsuDeckSettingsState createState() => KitsuDeckSettingsState();
}

class KitsuDeckSettingsState extends State<KitsuDeckSettings> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sharedPref = SharedPref();
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);
    if (kitsuDeck.hostname != null.toString() &&
        kitsuDeck.ip != null.toString()) {
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
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text("KitsuDeck Hostname: ${kitsuDeck.hostname!}"),
                          Text("KitsuDeck IP: ${kitsuDeck.ip!}"),
                          TextButton(
                            child: const Text("Remove KitsuDeck"),
                            onPressed: () async {
                              websocket.disconnect();
                              await kitsuDeck.removeKitsuDeckSettings();
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ))),
          )
        ],
      ));
    } else {
      return Expanded(child: NoKitsuDeck());
    }
  }
}
