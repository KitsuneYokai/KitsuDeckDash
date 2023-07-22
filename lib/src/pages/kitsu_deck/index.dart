import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/kitsu_deck/device.dart';
import '../../classes/websocket/connector.dart';
import '../settings/no_device.dart';
import 'macro/macro_dashboard.dart';

class KitsuDeckDashboard extends StatefulWidget {
  const KitsuDeckDashboard({
    Key? key,
  }) : super(key: key);

  @override
  KitsuDeckDashboardState createState() => KitsuDeckDashboardState();
}

class KitsuDeckDashboardState extends State<KitsuDeckDashboard> {
  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.9),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Spacer(),
                        const Icon(
                          Icons.tablet_android,
                          size: 50,
                        ),
                        Text(kitsuDeck.hostname),
                        Icon(
                          websocket.isConnected
                              ? Icons.check_circle
                              : Icons.error,
                          color:
                              websocket.isConnected ? Colors.green : Colors.red,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.code),
                                  onPressed: websocket.isConnected
                                      ? () async {
                                          showMacroDashboard(context);
                                        }
                                      : null,
                                ),
                                const Text("Macros"),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Expanded(child: NoKitsuDeck());
    }
  }
}
