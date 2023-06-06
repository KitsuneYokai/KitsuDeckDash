import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../classes/kitsu_deck/device.dart';
import '../../classes/websocket/connector.dart';
import '../../helper/network.dart';

class AddKitsuDeck extends StatefulWidget {
  const AddKitsuDeck({super.key});

  @override
  AddKitsuDeckState createState() => AddKitsuDeckState();
}

// TODO: Make better its pretty bad rn but it works for now
class AddKitsuDeckState extends State<AddKitsuDeck> {
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  int _selectedIndex = 0;
  // make a text controller
  final _ipConfigController = TextEditingController();
  final _pinConfigController = TextEditingController();

  String hostname = "";
  String ip = "";
  String pin = "";

  bool _isLoading = false;
  List<Map> _deckList = [];

  Future<void> _getIpList() async {
    setState(() {
      _isLoading = true;
    });

    _deckList = await getKitsuDeckHostname();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final gateway = Provider.of<DeckWebsocket>(context);
    return AlertDialog(
        title: Row(children: [
          const Text('Add a KitsuDeck'),
          const Spacer(),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          children: [
            // Automatic Kitsu Deck Detection
            if (_selectedIndex == 0) ...{
              Expanded(
                  child: Column(
                children: [
                  if (_isLoading) ...{
                    const CircularProgressIndicator(),
                    const Text("Loading KitsuDeck's"),
                  },
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var deck in _deckList) ...{
                          ListTile(
                            title: Text(deck['hostname']),
                            onTap: () {
                              setState(() {
                                hostname = deck['hostname'];
                                ip = deck['ip'];
                                // if the deck is protected go to page 2(pin enter page)
                                if (deck['protected']) {
                                  _selectedIndex = 2;
                                }
                                // else go to page 3 # final page(maybe renaming idk yet)
                                else {
                                  _selectedIndex = 3;
                                }
                              });
                            },
                            trailing: deck['protected']
                                ? const Icon(Icons.lock)
                                : const Icon(Icons.lock_open),
                          ),
                        }
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_isLoading ? Icons.refresh : Icons.refresh),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                        _deckList = [];
                      });
                      await _getIpList();
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // stop the future builder
                        _selectedIndex = 1;
                      });
                    },
                    child: const Text("Add Manually"),
                  )
                ],
              ))
              // Manual Kitsu Deck Detection
            } else if (_selectedIndex == 1) ...{
              Expanded(
                  child: Column(
                children: [
                  TextField(
                    onSubmitted: (value) async {
                      if (value.isNotEmpty && value.length > 7) {
                        var response = await kitsuDeckValidationCheck(value);
                        if (response != false) {
                          if (_selectedIndex == 1) {
                            setState(() {
                              hostname = response['hostname'];
                              ip = response['ip'];
                              // if the deck is protected go to page 2(pin enter page)
                              if (response['protected']) {
                                _selectedIndex = 2;
                              }
                              // else go to page 3 # final page(maybe renaming idk yet)
                              else {
                                _selectedIndex = 3;
                              }
                            });
                          }
                        } else {
                          if (_selectedIndex == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "KitsuDeck not found, please try again")));
                          }
                        }
                      }
                    },
                    controller: _ipConfigController,
                    maxLength: 15,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'IP Address',
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: const Text("Auto Detect KitsuDeck's"),
                  )
                ],
              ))
            } else if (_selectedIndex == 2) ...{
              Expanded(
                child: Column(children: [
                  TextField(
                    controller: _pinConfigController,
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        var pinCheck = await pinValidationCheck(ip, value);
                        if (pinCheck) {
                          setState(() {
                            pin = value;
                            _selectedIndex = 3;
                          });
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
            } else if (_selectedIndex == 3) ...{
              Expanded(
                  child: Column(
                children: [
                  const Text("Found KitsuDeck:"),
                  Text(hostname.split(".").first),
                  const Spacer(),
                  IconButton(
                      onPressed: () async {
                        await kitsuDeck.setKitsuDeckSettings(
                          hostname,
                          ip,
                          pin,
                        );
                        gateway.initConnection(
                            "ws://$hostname/ws", pin.toString());
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                      )),
                  const Text("Add KitsuDeck"),
                  const Spacer(),
                ],
              ))
            }
          ],
        ));
  }
}

showAddKitsuDeck(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return const AddKitsuDeck();
    },
  );
}
