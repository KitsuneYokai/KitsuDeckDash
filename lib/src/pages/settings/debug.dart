import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/kitsu_deck/connector.dart';
import '../../classes/kitsu_deck/device.dart';
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
  final logController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);
    if (logController.hasClients) {
      logController.animateTo(
        logController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // load image bin file from downloads folder
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Log:",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                decoration: BoxDecoration(
                                  // add border
                                  border: Border.all(
                                    color: Colors.grey[400]!,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SingleChildScrollView(
                                  controller: logController,
                                  child: Wrap(
                                    children: [
                                      const SizedBox(height: 10, width: 1),
                                      for (var log in kitsuDeck.logList) ...{
                                        // create a box with padding and margin + rounded corners
                                        LogMessage(
                                          log: log,
                                        ),
                                      }
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            child: const Text("Test Log Info"),
                            onPressed: () {
                              kitsuDeck.log("Test Log Info", LogType.info);
                            },
                          ),
                          TextButton(
                            child: const Text("Test Log Warning"),
                            onPressed: () {
                              kitsuDeck.log(
                                  "Test Log Warning", LogType.warning);
                            },
                          ),
                          TextButton(
                            child: const Text("Test Log Error"),
                            onPressed: () {
                              kitsuDeck.log("Test Log Error", LogType.error);
                            },
                          ),
                        ],
                      ),
                      const Text("KitsuDeck:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        child: const Text("Auth KitsuDeck"),
                        onPressed: () {
                          showAuthenticateKitsuDeck(context);
                        },
                      ),
                    ],
                  ))),
        )
      ],
    ));
  }
}

class LogMessage extends StatelessWidget {
  final Map log;

  const LogMessage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    var color = Colors.blue[300];
    if (log["type"] == LogType.warning.toString().split(".")[1]) {
      color = Colors.orange[400];
    } else if (log["type"] == LogType.error.toString().split(".")[1]) {
      color = Colors.red[300];
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          child: Container(
              margin: const EdgeInsets.only(bottom: 5, top: 5),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  log["message"],
                ),
              )),
        ),
        Positioned(
          top: 0,
          left: 5,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 3, top: 3, left: 5, right: 5),
                child: Row(
                  children: [
                    const Icon(
                      Icons.watch_later_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(log["time"])
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
