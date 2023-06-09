import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'add_macro.dart';
import 'macro_images.dart';
import 'macro_layout.dart';

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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    "Here will be a list of all your macros, + a search bar")
                              ],
                            ))),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () async {
                                bool? result = await showMacroModal(context);
                                if (result! == true) {
                                  SnackBar snackBar = const SnackBar(
                                    content: Text("Macro added!"),
                                    duration: Duration(seconds: 3),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              child: const Row(children: [
                                Icon(Icons.add),
                                Text("Add Macro")
                              ])),
                          TextButton(
                              onPressed: () {
                                showMacroImagesModal(context, false);
                              },
                              child: const Row(children: [
                                Icon(Icons.image_search_outlined),
                                Text("Macro Images")
                              ])),
                          TextButton(
                              onPressed: () {
                                showMacroLayoutEditorModal(context);
                              },
                              child: const Row(children: [
                                Icon(Icons.grid_view),
                                Text("Layout")
                              ])),
                        ],
                      ),
                    )
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
