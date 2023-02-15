import 'package:flutter/material.dart';
import '../ui.dart';

class KitsuDeckAdd extends StatelessWidget {
  static const routeName = '/device';

  const KitsuDeckAdd({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MainView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back)),
          const Text("  Add a KitsuDeck",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        ],
      ),
      Padding(
        padding:
            const EdgeInsets.only(top: 20.0, left: 50, right: 40, bottom: 20),
        child: Container(
            height: // set the height of the container to the height of the screen
                MediaQuery.of(context).size.height - 166,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  Theme.of(context).primaryColor.withOpacity(0.9),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text(
                    "Home",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Spacer(),
                  Text("I have no idea what to display here at the moment."),
                  Text("Maybe I will add a changelog here?")
                ],
              ),
            )),
      )
    ]));
  }
}
