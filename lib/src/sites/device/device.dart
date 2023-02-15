import 'package:flutter/material.dart';
import '../ui.dart';

class Device extends StatelessWidget {
  static const routeName = '/device';

  const Device({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MainView(child: Text("Device"));
  }
}
