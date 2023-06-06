import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'add_macro.dart';
import 'macro_images.dart';

class MacroDashboard extends StatefulWidget {
  const MacroDashboard({super.key});

  @override
  MacroDashboardState createState() => MacroDashboardState();
}

class MacroDashboardState extends State<MacroDashboard> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: DragToResizeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                      Theme.of(context).primaryColor.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: DragToMoveArea(
                              child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Macro Dashboard",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(Icons.close)),
                        )
                      ],
                    ),
                    const Text("HERE SHOW MACROS MAYBE?"),

                    // TODO: layout
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showMacroModal(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () {
                        showMacroImagesModal(context, false);
                      },
                    ),
                  ],
                )),
          ),
        ));
  }
}

showMacroDashboard(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const MacroDashboard();
    },
  );
}
