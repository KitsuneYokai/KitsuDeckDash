import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../classes/kitsu_deck/device.dart';
import '../../classes/websocket/connector.dart';
import '../../helper/network.dart';

class AuthKitsuDeck extends StatefulWidget {
  const AuthKitsuDeck({super.key});

  @override
  AuthKitsuDeckState createState() => AuthKitsuDeckState();
}

class AuthKitsuDeckState extends State<AuthKitsuDeck> {
  int _selectedIndex = 0;
  TextEditingController _pinConfigController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);
    return AlertDialog(
        // dont close dialog when tapped outside
        title: Row(children: [
          const Text('Authenticate'),
          const Spacer(),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          children: [
            Expanded(
              child: Column(children: [
                TextField(
                  controller: _pinConfigController,
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      var pinCheck =
                          await pinValidationCheck(kitsuDeck.ip, value);
                      if (pinCheck) {
                        await kitsuDeck.setKitsuDeckSettings(
                            kitsuDeck.hostname, kitsuDeck.ip, value);
                        websocket.setPin(value);
                        kitsuDeck.setPin(value);
                        if (!websocket.isConnected) {
                          websocket.initConnection(
                              "ws://${kitsuDeck.hostname}/ws", value);
                        }
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Pin is incorrect, please try again")));
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pin',
                  ),
                )
              ]),
            )
          ],
        ));
  }
}

showAuthenticateKitsuDeck(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return const AuthKitsuDeck();
    },
  );
}
