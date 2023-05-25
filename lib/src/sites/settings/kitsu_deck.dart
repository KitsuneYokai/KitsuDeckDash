import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../classes/kitsu_deck/device.dart';
import '../../classes/websocket/connector.dart';
import '../../helper/settingsStorage.dart';
import '../kitsu_deck/auth_device.dart';
import '../kitsu_deck/no_device.dart';

class KitsuDeckSettings extends StatefulWidget {
  const KitsuDeckSettings({
    Key? key,
  }) : super(key: key);

  @override
  KitsuDeckSettingsState createState() => KitsuDeckSettingsState();
}

class KitsuDeckSettingsState extends State<KitsuDeckSettings> {
  final _hostnameController = TextEditingController();
  int selectedIndex = 0;
  double _brightness = 10;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);

    if (kitsuDeck.hostname != null.toString() &&
        kitsuDeck.ip != null.toString()) {
      _hostnameController.text = kitsuDeck.hostname!.split("-")[1];
      if (!websocket.isConnected) {
        _isInit = false;
      }
      if (websocket.isConnected && !_isInit) {
        websocket.send(jsonEncode({"event": "GET_BRIGHTNESS"}));

        websocket.stream.firstWhere((event) {
          Map jsonData = jsonDecode(event);
          if (jsonData["event"] == "GET_BRIGHTNESS") {
            setState(() {
              _brightness = jsonData["value"] / 255 * 100;
              _isInit = true;
            });
            return true;
          }
          return false;
        });
      }
      return Expanded(
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
                  Theme.of(context).colorScheme.secondary.withOpacity(0.4),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "KitsuDeck Settings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextFormField(
                          enabled: false,
                          controller: _hostnameController,
                          decoration: const InputDecoration(
                            labelText: "Hostname",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "IP: ${kitsuDeck.ip}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        "Connected ",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        websocket.isConnected
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: websocket.isConnected
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        "Secured ",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        websocket.isSecured
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: websocket.isSecured
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        "Authenticated ",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        websocket.isAuthed
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: websocket.isAuthed
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (!websocket.isConnected &&
                                  websocket.isSecured &&
                                  !websocket.isAuthed)
                                ElevatedButton(
                                    onPressed: () async {
                                      showAuthenticateKitsuDeck(context);
                                    },
                                    child: const Text("Authenticate"))
                            ],
                          ),
                        ),
                        if (websocket.isConnected) ...{
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.brightness_low),
                              Slider(
                                value: _brightness,
                                max: 100,
                                min: 10,
                                divisions: 5,
                                label: _brightness.round().toString(),
                                onChanged: (double value) {
                                  // convert the value to be maximum 255 and minimum 10
                                  double newValue = value / 100 * 255;
                                  if (newValue < 10) {
                                    newValue = 10;
                                  }
                                  websocket.send(jsonEncode({
                                    "event": "SET_BRIGHTNESS",
                                    "value": "${newValue.round()}",
                                    "auth_pin": websocket.pin
                                  }));
                                  setState(() {
                                    _brightness = value;
                                  });
                                },
                              ),
                              const Icon(Icons.brightness_high),
                            ],
                          )
                        },
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            websocket.disconnect();
                            await kitsuDeck.removeKitsuDeckSettings();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete, color: Colors.white),
                                Text("Remove KitsuDeck",
                                    style: TextStyle(color: Colors.white)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Expanded(child: NoKitsuDeck());
    }
  }
}
