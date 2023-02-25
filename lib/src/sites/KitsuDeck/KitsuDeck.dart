import 'dart:convert';

import 'package:flutter/material.dart';

import 'KitsuDeckAdd.dart';
import 'KitsuDeckDevice.dart';
import '../ui.dart';
import '../../helper/settingsStorage.dart';

class KitsuDeck extends StatefulWidget {
  static const routeName = '/device';

  const KitsuDeck({Key? key}) : super(key: key);

  @override
  _KitsuDeckState createState() => _KitsuDeckState();
}

class _KitsuDeckState extends State<KitsuDeck> {
  SharedPref sharedPref = SharedPref();
  // create a state variable to store the list of devices
  var kitsuDeckSettings;
  void init() async {
    // get the list of devices from shared preferences
    var kitsuDeck = await sharedPref.read("kitsuDeck");
    setState(() {
      kitsuDeckSettings = kitsuDeck;
    });
  }

  // init the state variable
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
      title: "KitsuDeck",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              if (kitsuDeckSettings != null) ...[
                // create a container with rounded corners and a gradient background
                Container(
                    margin: const EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height - 110,
                    width: MediaQuery.of(context).size.width - 40,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.9),
                          Theme.of(context).primaryColor.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    // display the hostname of the device as link /clickable
                    child: Column(
                      // make the collum full height
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // make the collum full width
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // display the hostname of the device as link /clickable
                        Row(
                          children: [
                            Text(
                              jsonDecode(kitsuDeckSettings)["hostname"]
                                  .toString()
                                  .split(".")[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            )
                            //TODO: add ststus indicator (online/offline)
                          ],
                        ),
                        // display the ip address of the device
                        //TODO: instead of the spacer show a view of the kitsuDeck with the current display
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Delete button to remove the device
                            ElevatedButton(
                              onPressed: () async {
                                // remove the device from the list
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete KitsuDeck"),
                                        content: const Text(
                                            "Are you sure you want to delete this KitsuDeck?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await sharedPref
                                                  .remove("kitsuDeck");
                                              Navigator.of(context).pop();
                                              init();
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              style: //make it round and give padding and change background and
                                  ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: Colors.red.withOpacity(0.8),
                                padding: const EdgeInsets.all(10),
                                // give padding
                              ),
                              child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child:
                                      Icon(Icons.delete, color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return KitsuDeckDevice(
                                      KitsuDeckDeviceName: jsonDecode(
                                              kitsuDeckSettings)["hostname"]
                                          .toString()
                                          .split(".")[0]);
                                }));
                              },
                              style: //make it round and give padding and change background and
                                  ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: Colors.blue.withOpacity(0.7),
                                padding: const EdgeInsets.all(10),
                                // give padding
                              ),
                              child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.edit, color: Colors.white)),
                            ),
                          ],
                        )
                      ],
                    )),
              ] else ...[
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.9),
                        Theme.of(context).primaryColor.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        // display a big icon with a device and a plus sign
                        IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 100,
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const KitsuDeckAdd(),
                            ));
                          },
                        ),
                        const Text(
                          "Add a KitsuDeck device",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
