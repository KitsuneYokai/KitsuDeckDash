import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../classes/kitsu_deck/connector.dart';
import '../editor/editor.dart';
import '../images/images.dart';
import '../layout_editor/layout_editor.dart';

class MacroDashboard extends StatefulWidget {
  const MacroDashboard({super.key});

  @override
  MacroDashboardState createState() => MacroDashboardState();
}

class MacroDashboardState extends State<MacroDashboard> {
  bool isSent = false;

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);

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
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search Macro',
                    ),
                    onChanged: null, //TODO; search macro
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var macro in kitsuDeck.macroData) ...[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(children: [
                            if (macro["image_widget"] != null &&
                                macro["image_widget"] != null.toString())
                              macro["image_widget"],
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black.withOpacity(0.35),
                              ),
                              child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  onTap: () async {
                                    await showMacroInfoModal(context, macro);
                                  },
                                  child: Center(
                                    child: Text(
                                      macro["name"],
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ),
                          ]),
                        )
                      ]
                    ],
                  )),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () async {
                              bool? result =
                                  await showMacroEditorModal(context);
                              if (result! == true) {
                                SnackBar snackBar = const SnackBar(
                                  content: Text("Macro added!"),
                                  duration: Duration(seconds: 3),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                kitsuDeck.setMacroDataNull();
                                setState(() {
                                  isSent = false;
                                });
                              }
                            },
                            child: const Row(children: [
                              Icon(Icons.add),
                              Text("Add Macro")
                            ])),
                        TextButton(
                            onPressed: () async {
                              await showMacroImagesModal(context, false);
                              // refresh the site
                            },
                            child: const Row(children: [
                              Icon(Icons.image_search_outlined),
                              Text("Macro Images")
                            ])),
                        TextButton(
                            onPressed: () async {
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
      ),
    );
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

class MacroInfoModal extends StatefulWidget {
  final Map macro;
  const MacroInfoModal({super.key, required this.macro});

  @override
  MacroInfoModalState createState() => MacroInfoModalState();
}

class MacroInfoModalState extends State<MacroInfoModal> {
  bool isLoaded = false;
  bool isGetMacroSent = false;
  Map macroData = {};
  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);
    if (kitsuDeck.isConnected && !isLoaded && mounted) {
      if (!isGetMacroSent) {
        kitsuDeck.send(jsonEncode({
          "event": "GET_MACRO",
          "auth_pin": kitsuDeck.pin,
          "macro_id": widget.macro["id"],
        }));
        setState(() {
          isGetMacroSent = true;
        });
      }
      kitsuDeck.stream.firstWhere((value) {
        Map data = jsonDecode(value);
        if (data["event"] == "GET_MACRO" && !isLoaded) {
          if (data["status"] == true) {
            if (mounted) {
              setState(() {
                isLoaded = true;
                macroData = data["macro"];
              });
            }
          }
        }
        return false;
      });
    }
    return AlertDialog(
      content: Column(children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.macro["image_widget"] == null ||
                  widget.macro["image_widget"] == null.toString()) ...{
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    "assets/images/macro_icon.jpg",
                    fit: BoxFit.cover,
                  ),
                )
              } else ...{
                widget.macro["image_widget"]
              },
              Column(
                children: [
                  Text(widget.macro["name"],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(macroData["description"] ?? ""),
                ],
              ),
            ]),
        const SizedBox(height: 10),
        if (macroData.isNotEmpty) ...{
          if (jsonDecode(macroData["action"])["type"] == 0)
            const Text("Type: Macro", style: TextStyle(fontSize: 20)),
          const Text("From left to right:", style: TextStyle(fontSize: 20)),
          Flexible(
              child: Wrap(
            children: [
              for (var index = 0;
                  index < jsonDecode(macroData["action"])["action"].length;
                  index++)
                Container(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                    ),
                    onPressed: null,
                    child: Text(
                      jsonDecode(macroData["action"])["action"][index]["key"],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
            ],
          )),
          Text("Invoked: ${macroData["invoked"]}")
        },
      ]),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close")),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Widget image = ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  "assets/images/macro_icon.jpg", // "assets/images/app_icon.png
                  width: 100,
                  height: 100,
                ),
              );

              for (var macro in kitsuDeck.macroData) {
                if (macro["id"] == macroData["id"]) {
                  image = macro["image_widget"];
                }
              }

              bool? result = await showMacroEditorModal(
                  context,
                  macroData["id"],
                  macroData["name"],
                  macroData["description"],
                  jsonDecode(macroData["action"])["action"],
                  jsonDecode(macroData["action"])["type"],
                  image,
                  macroData["image"]);
              if (result != null && result) {
                Navigator.of(context).pop(true);
                setState(() {
                  isGetMacroSent = false;
                });
              }
            },
            child: const Text("Edit")),
      ],
    );
  }
}

Future<bool?> showMacroInfoModal(BuildContext context, Map macro) async {
  return await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return MacroInfoModal(
        macro: macro,
      );
    },
  );
}
