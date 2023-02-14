import 'package:flutter/material.dart';
import '../ui.dart';

class Home extends StatelessWidget {
  static const routeName = '/home';

  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MainView(child: Text("Test"));
  }
}
