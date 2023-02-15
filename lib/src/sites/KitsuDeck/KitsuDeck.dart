import 'package:flutter/material.dart';

import './KitsuDeckAdd.dart';
import '../ui.dart';

class KitsuDeck extends StatelessWidget {
  static const routeName = '/device';

  const KitsuDeck({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MainView(
        title: "KitsuDeck",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
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
                              fontSize: 25),
                        ),
                        // display a big icon with a device and a plus sign
                        IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 100,
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const KitsuDeckAdd()));
                          },
                        ),
                        Text("Add a KitsuDeck device",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
