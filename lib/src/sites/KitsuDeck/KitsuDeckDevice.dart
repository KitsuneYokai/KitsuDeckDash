import 'dart:convert';

import 'package:flutter/material.dart';

import '../ui.dart';
import './Macros/Makros.dart';

// create me a new class called KitsuDeckDevice thats stateless
class KitsuDeckDevice extends StatelessWidget {
  // create a state variable to store the list of devices
  final KitsuDeckDeviceName;
  // create a constructor that takes in the list of devices
  const KitsuDeckDevice({Key? key, required this.KitsuDeckDeviceName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainView(
      canGoBack: true,
      title: KitsuDeckDeviceName,
      child: Wrap(
          clipBehavior: Clip.none,
          verticalDirection: VerticalDirection.down,
          children: [
            //create a container with rounded corners and a gradient background
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                    Theme.of(context).primaryColor.withOpacity(0.9)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // button to redirect to makro view page
                  const Text("Makros",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KitsuDeckMakros(
                              KitsuDeckDeviceName: KitsuDeckDeviceName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward)),
                ],
              ),
            ),
          ]),
    );
  }
}
