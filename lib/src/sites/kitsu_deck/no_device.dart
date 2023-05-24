import 'package:flutter/material.dart';

import 'add_device.dart';

class NoKitsuDeck extends StatefulWidget {
  const NoKitsuDeck({
    Key? key,
  }) : super(key: key);

  @override
  NoKitsuDeckState createState() => NoKitsuDeckState();
}

class NoKitsuDeckState extends State<NoKitsuDeck> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          // add gradient from top left top bottom right
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Spacer(),
            const Text("You don't have any KitsuDeck's added yet!"),
            TextButton(
                onPressed: () {
                  showAddKitsuDeck(context);
                },
                child: const Text("Add a KitsuDeck")),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
