import 'package:flutter/material.dart';
import '../ui.dart';

class Home extends StatelessWidget {
  static const routeName = '/';

  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // generate a full sized container with rounded corners and a gradient background
    return MainView(
        title: "Home",
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20.0, left: 50, right: 40, bottom: 20),
          child: Container(
              height: // set the height of the container to the height of the screen
                  MediaQuery.of(context).size.height - 140,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Changelog:",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ));
  }
}
