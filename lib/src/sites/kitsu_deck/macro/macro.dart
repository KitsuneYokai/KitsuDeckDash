import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitsu_deck_dash/src/sites/kitsu_deck/macro/macro_images.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../classes/kitsu_deck/device.dart';
import '../../../classes/websocket/connector.dart';

const List<String> macroActions = <String>["Macro"];

class MacroModal extends StatefulWidget {
  const MacroModal({super.key});

  @override
  MacroModalState createState() => MacroModalState();
}

class MacroModalState extends State<MacroModal> {
  Map _imageB64Return = {};
  int macroActionsValue = 0;
  bool isMacroRecording = false;
  List macroRecording = [];

  void _handleKeyDownEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // if keys are pressed down then add them to the macroRecording list
      setState(() {
        var key = event.logicalKey.keyLabel;
        var code = event.logicalKey.keyId;
        if (key == " ") {
          key = "SPACE";
        }
        macroRecording = [
          ...macroRecording,
          {"key": key, "code": code}
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: DragToResizeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                      const Expanded(
                        child: DragToMoveArea(
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Add Macro",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () async {
                            if (isMacroRecording) {
                              RawKeyboard.instance
                                  .removeListener(_handleKeyDownEvent);
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: const [
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Macro Name',
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                minLines: 3,
                                maxLines: 3,
                                maxLength: 500,
                                decoration: InputDecoration(
                                  labelText: 'Macro Description',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              if (_imageB64Return.isEmpty) ...{
                                Container(
                                  width: 158,
                                  height: 158,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[700]!,
                                      width: 3,
                                    ),
                                  ),
                                  child: InkWell(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color:
                                                Colors.white.withOpacity(0.5),
                                          ),
                                          const Text(
                                            "Add Image",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      onTap: () async {
                                        final imageData =
                                            await showMacroImagesModal(
                                                context, true);
                                        setState(() {
                                          _imageB64Return = imageData!;
                                        });
                                      }),
                                )
                              } else ...{
                                SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: _imageB64Return["image"]),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _imageB64Return = {};
                                    });
                                  },
                                )
                              }
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButton(
                    hint: const Text("Select Action"),
                    value: macroActions[macroActionsValue],
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (value) => setState(() {
                      macroActionsValue = macroActions.indexOf(value!);
                    }),
                    items: macroActions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: const TextStyle(fontSize: 20)),
                      );
                    }).toList(),
                  ),
                  if (macroActionsValue == 0) ...{
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMacroRecording
                                        ? Colors.white70
                                        : Colors.white,
                                  ),
                                  child: Icon(
                                    isMacroRecording
                                        ? Icons.stop
                                        : Icons.circle,
                                    color: isMacroRecording
                                        ? Colors.red
                                        : Colors.green,
                                    size: isMacroRecording ? 20 : 15,
                                  ),
                                  onPressed: () async {
                                    if (isMacroRecording) {
                                      RawKeyboard.instance
                                          .removeListener(_handleKeyDownEvent);
                                    } else {
                                      RawKeyboard.instance
                                          .addListener(_handleKeyDownEvent);
                                    }
                                    setState(() {
                                      isMacroRecording = !isMacroRecording;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                DragTarget<int>(
                                  builder: (
                                    BuildContext context,
                                    List<dynamic> accepted,
                                    List<dynamic> rejected,
                                  ) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          macroRecording = [];
                                        });
                                      },
                                    );
                                  },
                                  onAccept: (int? acceptedIndex) {
                                    if (acceptedIndex != null) {
                                      setState(() {
                                        macroRecording.removeAt(acceptedIndex);
                                      });
                                    }
                                  },
                                  onWillAccept: (int? acceptedIndex) {
                                    return acceptedIndex != null;
                                  },
                                ),
                              ],
                            ),
                            if (macroRecording.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    clipBehavior: Clip.antiAlias,
                                    children: [
                                      for (var index = 0;
                                          index < macroRecording.length;
                                          index++)
                                        Draggable(
                                          data: index,
                                          feedback: Material(
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white70,
                                                ),
                                                onPressed: null,
                                                child: Text(
                                                  macroRecording[index]["key"],
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Container(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: DragTarget<int>(
                                              builder: (
                                                BuildContext context,
                                                List<dynamic> accepted,
                                                List<dynamic> rejected,
                                              ) {
                                                return ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white70,
                                                  ),
                                                  child: Text(
                                                    macroRecording[index]
                                                        ["key"],
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                  onPressed: () async {},
                                                );
                                              },
                                              onAccept: (int? acceptedIndex) {
                                                if (acceptedIndex != null) {
                                                  setState(() {
                                                    final draggedItem =
                                                        macroRecording[
                                                            acceptedIndex];
                                                    macroRecording.removeAt(
                                                        acceptedIndex);
                                                    macroRecording.insert(
                                                        index, draggedItem);
                                                  });
                                                }
                                              },
                                              onWillAccept:
                                                  (int? acceptedIndex) {
                                                return acceptedIndex != null;
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          children: const [
                                            Icon(Icons.save,
                                                color: Colors.white),
                                            Text(" Save Macro",
                                                style: TextStyle(
                                                    color: Colors.white))
                                          ],
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ],
                        ),
                      ),
                    ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

showMacroModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const MacroModal();
    },
  );
}
