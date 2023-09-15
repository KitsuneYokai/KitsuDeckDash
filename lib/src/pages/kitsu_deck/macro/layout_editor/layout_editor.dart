import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitsu_deck_dash/src/classes/kitsu_deck/connector.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class MacroLayoutEditor extends StatefulWidget {
  const MacroLayoutEditor({super.key});

  @override
  MacroLayoutEditorState createState() => MacroLayoutEditorState();
}

class MacroLayoutEditorState extends State<MacroLayoutEditor> {
  final int _maxMacroPerPage = 20; // max macro per page
  int _currentMacroPage =
      0; // current macro page if 0 = first page 1-20, if 1-99: X*_maxMacro + macroPosition(1-20)

  final TextEditingController _macroPageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _macroPageController.text = (_currentMacroPage + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);

    List macroWidgets = [];

    var maxPosition = _currentMacroPage * _maxMacroPerPage;

    for (var i = 1; i <= _maxMacroPerPage; i++) {
      Map macroMap = {
        "id": null,
        "name": "",
        "image": null,
        "image_widget": null,
        "layout_position": (i + maxPosition).toString(),
      }; // Initialize with default value

      for (var macro in kitsuDeck.macroData) {
        var layoutPosition = macro["layout_position"];
        if (layoutPosition == (i + maxPosition).toString()) {
          macroMap = macro;
          break;
        }
      }
      macroWidgets.add(macroMap);
    }
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DragToResizeArea(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.6),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    DragToMoveArea(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 118,
                        height: 55,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Layout Editor",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(false);
                        },
                        child: const Icon(Icons.close),
                      ),
                    )
                  ],
                ),
                Flexible(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // show macro list to drag and drop them into the layout
                    SizedBox(
                      width: 235,
                      child: Column(children: [
                        const Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Macro Name',
                            ),
                          ),
                        ),
                        Flexible(
                            child: SingleChildScrollView(
                          child: Wrap(runSpacing: 10, spacing: 10, children: [
                            for (var macro in kitsuDeck.macroData) ...[
                              Draggable(
                                  data: macro["id"],
                                  feedback: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // background color
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: Center(
                                        child: Text(macro["name"],
                                            maxLines: 1,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                decoration:
                                                    TextDecoration.none)),
                                      )),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      // background color
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.asset(
                                            "assets/images/macro_icon.jpg",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (macro["image_widget"] != null)
                                          macro["image_widget"],
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            // background color
                                            color:
                                                Colors.black.withOpacity(0.3),
                                          ),
                                          child: Center(
                                            child: Text(
                                              macro["name"],
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            ]
                          ]),
                        )),
                      ]),
                    ),
                    Expanded(
                        child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary, // foreground
                              ),
                              onPressed: () {
                                if (_currentMacroPage > 0) {
                                  _currentMacroPage--;
                                  setState(() {
                                    _macroPageController.text =
                                        (_currentMacroPage + 1).toString();
                                  });
                                }
                              },
                              child: const Icon(Icons.arrow_back)),
                          const Spacer(),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value != "" &&
                                    value != null.toString() &&
                                    value != "0" &&
                                    int.parse(value) <= 100) {
                                  setState(() {
                                    _currentMacroPage = int.parse(value) - 1;
                                  });
                                }
                              },
                              controller: _macroPageController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Page',
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary, // foreground
                              ),
                              onPressed: () {
                                if (_currentMacroPage < 99) {
                                  _currentMacroPage++;

                                  setState(() {
                                    _macroPageController.text =
                                        (_currentMacroPage + 1).toString();
                                  });
                                }
                              },
                              child: const Icon(Icons.arrow_forward)),
                          const Spacer(),
                        ],
                      ),
                      Flexible(
                          child: Center(
                        child: SizedBox(
                            width: 550,
                            child: Wrap(spacing: 10, runSpacing: 5, children: [
                              for (var macro in macroWidgets) ...[
                                DragTarget(builder:
                                    (context, candidateData, rejectedData) {
                                  return SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          // background color
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                        child: Stack(
                                          children: [
                                            if (macro["image_widget"] != null)
                                              macro["image_widget"],
                                            if (macro["name"] != "") ...[
                                              Center(
                                                  child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // background color
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    macro["name"],
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              )),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.white,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      elevation: 0,
                                                      padding: EdgeInsets.zero,
                                                      minimumSize:
                                                          const Size(2, 2),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)))),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(3),
                                                    child: Icon(
                                                      Icons.delete,
                                                      size: 20,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    int layoutPosition =
                                                        int.parse(macro[
                                                            "layout_position"]);
                                                    kitsuDeck.send(jsonEncode({
                                                      "event":
                                                          "UPDATE_MACRO_LAYOUT",
                                                      "auth_pin": kitsuDeck.pin,
                                                      "macro_id": "Null",
                                                      "layout_position":
                                                          layoutPosition
                                                    }));
                                                  },
                                                ),
                                              )
                                            ],
                                            // show layout position
                                            Positioned(
                                                child: Container(
                                                    width: 35,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      // background color
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        macro[
                                                            "layout_position"],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ))),
                                          ],
                                        ),
                                      ));
                                }, onAccept: (data) {
                                  int layoutPosition =
                                      int.parse(macro["layout_position"]);
                                  kitsuDeck.send(jsonEncode({
                                    "event": "UPDATE_MACRO_LAYOUT",
                                    "auth_pin": kitsuDeck.pin,
                                    "macro_id": data,
                                    "layout_position": layoutPosition
                                  }));
                                }),
                              ]
                            ])),
                      ))
                    ]))
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> showMacroLayoutEditorModal(BuildContext context) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const MacroLayoutEditor();
    },
  );
}
