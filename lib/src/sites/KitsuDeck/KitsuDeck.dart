import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/settingsStorage.dart';

import './KitsuDeckAdd.dart';
import '../ui.dart';

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
                  child: Text(jsonDecode(kitsuDeckSettings)["hostname"]),
                ),
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
