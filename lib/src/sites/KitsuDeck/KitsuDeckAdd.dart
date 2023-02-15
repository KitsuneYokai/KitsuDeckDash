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
        title: "Add a KitsuDeck",
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: const EdgeInsets.all(20),
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
        ]));
  }
}
