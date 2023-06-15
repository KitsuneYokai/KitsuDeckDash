import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../classes/kitsu_deck/device.dart';

class MacroLayoutEditor extends StatefulWidget {
  const MacroLayoutEditor({super.key});

  @override
  MacroLayoutEditorState createState() => MacroLayoutEditorState();
}

class MacroLayoutEditorState extends State<MacroLayoutEditor> {
  final int _maxMacroPerPage = 20; // max macro per page
  int _currentMacroPage =
      0; // current macro page if 0 = first page 1-20, if 1-99: X*_maxMacro + macroPosition(1-20)

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);

    List macroWidgets = [];
    List newMacroWidgets = [];

    var maxPosition = _currentMacroPage * _maxMacroPerPage;

    for (var i = 1; i <= _maxMacroPerPage; i++) {
      Map macroMap = {
        "id": null,
        "name": "",
        "image": null,
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
      newMacroWidgets.add(macroMap);
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
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // background color
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.asset(
                                        "assets/images/macro_icon.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (macro["image"] != null ||
                                        macro["image"] != null.toString()) ...[
                                      for (var image
                                          in kitsuDeck.macroImages) ...[
                                        if (image["id"] == macro["image"]) ...[
                                          image["image"]
                                        ]
                                      ]
                                    ],
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        // background color
                                        color: Colors.black.withOpacity(0.3),
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
                              )
                            ]
                          ]),
                        )),
                      ]),
                    ),
                    // TODO: layout Editor starts here
                    Expanded(
                        child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_currentMacroPage > 0) {
                                    _currentMacroPage--;
                                  }
                                });
                              },
                              child: const Icon(Icons.arrow_back)),
                          Text((_currentMacroPage + 1).toString()),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentMacroPage++;
                                });
                              },
                              child: const Icon(Icons.arrow_forward)),
                        ],
                      ),
                      Flexible(
                          child: Center(
                        child: SizedBox(
                            width: 550,
                            child: Wrap(spacing: 10, runSpacing: 5, children: [
                              for (var macro in macroWidgets) ...[
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // background color
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: Stack(
                                    children: [
                                      if (macro["image"] != null ||
                                          macro["image"] !=
                                              null.toString()) ...[
                                        for (var image
                                            in kitsuDeck.macroImages) ...[
                                          if (image["id"] ==
                                              macro["image"]) ...[
                                            image["image"]
                                          ]
                                        ]
                                      ],
                                      // show macro name
                                      if (macro["name"] != "" &&
                                          (macro["image"] == "null" ||
                                              macro["image"] ==
                                                  null.toString()))
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.asset(
                                            "assets/images/macro_icon.jpg",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      if (macro["name"] != "")
                                        Center(
                                            child: Container(
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
                                        )),
                                      // show layout position
                                      Positioned(
                                          child: Container(
                                              width: 35,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                // background color
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  macro["layout_position"],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ))),
                                    ],
                                  ),
                                )
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
      return MacroLayoutEditor();
    },
  );
}
