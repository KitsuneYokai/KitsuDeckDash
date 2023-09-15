import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_device.dart';
import 'no_device.dart';

import '../../classes/kitsu_deck/connector.dart';

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
    final kitsuDeck = Provider.of<DeckWebsocket>(context);

    if (kitsuDeck.hostname != null.toString() &&
        kitsuDeck.ip != null.toString()) {
      _hostnameController.text = kitsuDeck.hostname!.split("-")[1];
      if (!kitsuDeck.isConnected) {
        _isInit = false;
      }
      if (kitsuDeck.isConnected && !_isInit) {
        kitsuDeck.send(jsonEncode({"event": "GET_BRIGHTNESS"}));

        kitsuDeck.stream.firstWhere((event) {
          Map jsonData = jsonDecode(event);
          if (jsonData["event"] == "GET_BRIGHTNESS") {
            if (mounted) {
              setState(() {
                _brightness = jsonData["value"] / 255 * 100;
                if (_brightness < 10) {
                  _brightness = 10;
                }
                _isInit = true;
              });
            }
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
                            border: OutlineInputBorder(
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
                                        kitsuDeck.isConnected
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: kitsuDeck.isConnected
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
                                        kitsuDeck.isSecured
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: kitsuDeck.isSecured
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
                                        kitsuDeck.isAuthed
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: kitsuDeck.isAuthed
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Text("TODO: Add clock UTC offset")
                                ],
                              ),
                              if (!kitsuDeck.isConnected &&
                                  kitsuDeck.isSecured &&
                                  !kitsuDeck.isAuthed)
                                ElevatedButton(
                                    onPressed: () async {
                                      showAuthenticateKitsuDeck(context);
                                    },
                                    child: const Text("Authenticate"))
                            ],
                          ),
                        ),
                        if (kitsuDeck.isConnected) ...{
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.brightness_low),
                              Flexible(
                                  flex: 3,
                                  child: Slider(
                                    value: _brightness,
                                    max: 100,
                                    min: 10,
                                    divisions: 4,
                                    label: _brightness.round().toString(),
                                    onChanged: (double value) {
                                      // convert the value to be maximum 255 and minimum 10
                                      double newValue = value / 100 * 255;
                                      if (newValue < 10) {
                                        newValue = 10;
                                      }
                                      kitsuDeck.send(jsonEncode({
                                        "event": "SET_BRIGHTNESS",
                                        "value": "${newValue.round()}",
                                        "auth_pin": kitsuDeck.pin
                                      }));
                                      setState(() {
                                        _brightness = value;
                                      });
                                    },
                                  )),
                              const Icon(Icons.brightness_high),
                            ],
                          )
                        },
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            kitsuDeck.disconnect();
                            await kitsuDeck.removeKitsuDeckSettings();
                            setState(() {
                              _isInit = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
