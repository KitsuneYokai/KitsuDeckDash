import 'package:flutter/material.dart';
import '../../helper/navbar.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              const WindowButtons(),
              Expanded(
                child: Container(
                  color: Colors.red,
                ),
              )
            ],
          )),
    );
  }
}
