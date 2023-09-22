import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_invoker/keyboard_invoker.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../images/images.dart';
import '../../../../classes/kitsu_deck/connector.dart';

const List<String> macroActions = <String>["Macro"];

// macro Types definitions, is used in the deck to know what type of macro it is
int macroAction = 0; // macro = keyboard key emulation (e.g. "Hello world")
int fnAction = 1; // fn = function key emulation (F1-F...)
int programAction = 2; // program = open programs (Open Chrome,  Discord, etc)

class MacroEditorModal extends StatefulWidget {
  final String? macroId;
  final String? macroName;
  final String? macroDescription;
  final List? macroRecording;
  final int? macroType;
  final Widget? imageData;
  final String? imageId;

  const MacroEditorModal(
      {super.key,
      this.macroId,
      this.macroName,
      this.macroDescription,
      this.macroRecording,
      this.macroType,
      this.imageData,
      this.imageId});

  @override
  MacroEditorModalState createState() => MacroEditorModalState();
}

class MacroEditorModalState extends State<MacroEditorModal> {
  // init state if macro is being edited
  bool isEditingMode = false;
  String imageId = null.toString();

  @override
  void initState() {
    super.initState();
    if (widget.macroName != null) {
      macroNameController.text = widget.macroName!;
      isEditingMode = true;
    }
    if (widget.macroDescription != null) {
      macroDescriptionController.text = widget.macroDescription!;
    }
    if (widget.macroRecording != null) {
      _recordedKeys = widget.macroRecording!;
    }
    if (widget.macroType != null) {
      macroAction = widget.macroType!;
    }
    if (widget.imageData != null) {
      _imageReturn = {"image": widget.imageData!};
    }
    if (widget.imageId != null) {
      imageId = widget.imageId!;
    }
  }

  Map _imageReturn = {};
  int macroActionsValue = 0;
  List _recordedKeys = [];
  bool _isRecording = false;

  TextEditingController macroNameController = TextEditingController();
  TextEditingController macroDescriptionController = TextEditingController();
  // simple macro recording function
  recordKeys(RawKeyEvent event) {
    String keyLabel = event.logicalKey.keyLabel;
    int keyCode = event.logicalKey.keyId;

    bool isRepeat = event.repeat;

    Map<String, dynamic> macroMap = {
      "keyLabel": null,
      "code": null,
      "event": null,
    };

    // don't record the key if it's a repeated event
    if (!isRepeat) {
      // only record the modifier keys on a key down event
      if (event is RawKeyDownEvent) {
        if (keyLabel.toLowerCase().contains("shift") ||
            keyLabel.toLowerCase().contains("control") ||
            keyLabel.toLowerCase().contains("alt") ||
            keyLabel.toLowerCase().contains("meta")) {
          macroMap["keyLabel"] = keyLabel;
          macroMap["code"] = keyCode;
          macroMap["event"] = KeyType.keyDown.toString();

          setState(() {
            _recordedKeys = [..._recordedKeys, macroMap];
          });
        }
        // record the keys on a key up event, so they are not held down
      } else if (event is RawKeyUpEvent) {
        macroMap["keyLabel"] = keyLabel;
        macroMap["code"] = keyCode;
        macroMap["event"] = KeyType.keyInvoke.toString();

        if (keyLabel.toLowerCase().contains("shift") ||
            keyLabel.toLowerCase().contains("ctrl") ||
            keyLabel.toLowerCase().contains("alt") ||
            keyLabel.toLowerCase().contains("meta")) {
          macroMap["event"] = KeyType.keyUp.toString();
        }
        // set the state
        setState(() {
          _recordedKeys = [..._recordedKeys, macroMap];
        });
      }
    }
  }

  startRecording() {
    // clear the recorded keys
    setState(() {
      _recordedKeys = [];
      _isRecording = true;
    });
    // add the listener
    RawKeyboard.instance.addListener(recordKeys);
  }

  stopRecording() {
    // remove the listener
    RawKeyboard.instance.removeListener(recordKeys);
    // set the state
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DragToResizeArea(
          child: Container(
            margin: const EdgeInsets.all(20),
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
                    Expanded(
                      child: DragToMoveArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              isEditingMode ? "Edit Macro" : "Add Macro",
                              style: const TextStyle(
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
                          if (_isRecording) {
                            stopRecording();
                          }
                          Navigator.of(context).pop(false);
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
                          children: [
                            TextField(
                              controller: macroNameController,
                              decoration: const InputDecoration(
                                labelText: 'Macro Name',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: macroDescriptionController,
                              minLines: 3,
                              maxLines: 3,
                              maxLength: 500,
                              decoration: const InputDecoration(
                                labelText: 'Macro Description',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (_imageReturn.isEmpty) ...{
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
                                          color: Colors.white.withOpacity(0.5),
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
                                        _imageReturn = imageData!;
                                      });
                                    }),
                              )
                            } else ...{
                              SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: _imageReturn["image_widget"]),
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
                                    imageId = null.toString();
                                    _imageReturn = {};
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
                      child: Text(value, style: const TextStyle(fontSize: 20)),
                    );
                  }).toList(),
                ),
                if (macroActionsValue == macroAction) ...{
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isRecording
                                      ? Colors.white70
                                      : Colors.white,
                                ),
                                child: Icon(
                                  _isRecording ? Icons.stop : Icons.circle,
                                  color:
                                      _isRecording ? Colors.red : Colors.green,
                                  size: _isRecording ? 20 : 15,
                                ),
                                onPressed: () async {
                                  if (_isRecording) {
                                    stopRecording();
                                  } else {
                                    startRecording();
                                  }
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
                                        _recordedKeys = [];
                                      });
                                    },
                                  );
                                },
                                onAccept: (int? acceptedIndex) {
                                  if (acceptedIndex != null) {
                                    setState(() {
                                      _recordedKeys.removeAt(acceptedIndex);
                                    });
                                  }
                                },
                                onWillAccept: (int? acceptedIndex) {
                                  return acceptedIndex != null;
                                },
                              ),
                            ],
                          ),
                          if (_recordedKeys.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Wrap(
                                  clipBehavior: Clip.antiAlias,
                                  children: [
                                    for (var index = 0;
                                        index < _recordedKeys.length;
                                        index++)
                                      Draggable(
                                        data: index,
                                        feedback: Material(
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white70,
                                              ),
                                              onPressed: null,
                                              child: Text(
                                                _recordedKeys[index]
                                                    ["keyLabel"],
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white70,
                                                ),
                                                child: Text(
                                                  _recordedKeys[index]
                                                      ["keyLabel"],
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
                                                      _recordedKeys[
                                                          acceptedIndex];
                                                  _recordedKeys
                                                      .removeAt(acceptedIndex);
                                                  _recordedKeys.insert(
                                                      index, draggedItem);
                                                });
                                              }
                                            },
                                            onWillAccept: (int? acceptedIndex) {
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
                                if (isEditingMode) ...{
                                  Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () async {
                                            bool? result =
                                                await showMacroEditorConfirmModal(
                                                    context,
                                                    macroActionsValue,
                                                    macroNameController.text,
                                                    macroDescriptionController
                                                        .text,
                                                    _recordedKeys,
                                                    _imageReturn,
                                                    isEditingMode,
                                                    widget.macroId,
                                                    widget.imageId,
                                                    true);
                                            if (result != null && result) {
                                              Navigator.pop(context, true);
                                            }
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.white),
                                              Text(" Delete Macro",
                                                  style: TextStyle(
                                                      color: Colors.white))
                                            ],
                                          ))),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () async {
                                          // remove the listener for the macro recording
                                          stopRecording();
                                          // check if the macro is empty
                                          if (_recordedKeys.isEmpty) {
                                            const snackBar = SnackBar(
                                              content:
                                                  Text("Please record a macro"),
                                              duration: Duration(seconds: 3),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                          if (macroNameController
                                              .text.isEmpty) {
                                            // create a snackbar message
                                            const snackBar = SnackBar(
                                              content: Text(
                                                  "Please enter a macro name"),
                                              duration: Duration(seconds: 3),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                          if (_recordedKeys.isNotEmpty &&
                                              macroNameController
                                                  .text.isNotEmpty) {
                                            // save the macro
                                            bool? result =
                                                await showMacroEditorConfirmModal(
                                              context,
                                              macroActionsValue,
                                              macroNameController.text,
                                              macroDescriptionController.text,
                                              _recordedKeys,
                                              _imageReturn,
                                              isEditingMode,
                                              widget.macroId,
                                              imageId,
                                            );
                                            if (result != null &&
                                                result == true) {
                                              SnackBar snackBar =
                                                  const SnackBar(
                                                content: Text(
                                                    "Macro saved successfully"),
                                                duration: Duration(seconds: 3),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                              Navigator.pop(context, true);
                                            }
                                          }
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit,
                                                color: Colors.white),
                                            Text(" Edit Macro",
                                                style: TextStyle(
                                                    color: Colors.white))
                                          ],
                                        )),
                                  )
                                },
                                if (!isEditingMode) ...{
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () async {
                                          // remove the listener for the macro recording
                                          stopRecording();

                                          // check if the macro is empty
                                          if (_recordedKeys.isEmpty) {
                                            const snackBar = SnackBar(
                                              content:
                                                  Text("Please record a macro"),
                                              duration: Duration(seconds: 3),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                          if (macroNameController
                                              .text.isEmpty) {
                                            // create a snackbar message
                                            const snackBar = SnackBar(
                                              content: Text(
                                                  "Please enter a macro name"),
                                              duration: Duration(seconds: 3),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                          if (_recordedKeys.isNotEmpty &&
                                              macroNameController
                                                  .text.isNotEmpty) {
                                            // save the macro
                                            bool? result =
                                                await showMacroEditorConfirmModal(
                                              context,
                                              macroActionsValue,
                                              macroNameController.text,
                                              macroDescriptionController.text,
                                              _recordedKeys,
                                              _imageReturn,
                                              isEditingMode,
                                            );
                                            if (result != null &&
                                                result == true) {
                                              Navigator.pop(context, true);
                                            }
                                          }
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.save,
                                                color: Colors.white),
                                            Text(" Save Macro",
                                                style: TextStyle(
                                                    color: Colors.white))
                                          ],
                                        )),
                                  ),
                                }
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
    );
  }
}

Future<bool?> showMacroEditorModal(BuildContext context,
    [String? macroId,
    String? macroName,
    String? macroDescription,
    List? macroRecording,
    int? macroType,
    Widget? imageData,
    String? imageId]) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return MacroEditorModal(
        macroId: macroId,
        macroName: macroName,
        macroDescription: macroDescription,
        macroRecording: macroRecording,
        macroType: macroType,
        imageData: imageData,
        imageId: imageId,
      );
    },
  );
}

class MacroEditorConfirmModal extends StatefulWidget {
  final String? macroId;
  final int macroAction;
  final String macroName;
  final String macroDescription;
  final List<dynamic> macroRecording;
  final Map<dynamic, dynamic> macroImageData;
  final bool isEditingMode;
  final String? imageId;
  final bool? isDeleteMode;
  const MacroEditorConfirmModal(
      {super.key,
      required this.macroAction,
      required this.macroName,
      required this.macroDescription,
      required this.macroRecording,
      required this.macroImageData,
      required this.isEditingMode,
      this.macroId,
      this.imageId,
      this.isDeleteMode});

  @override
  MacroEditorConfirmModalState createState() => MacroEditorConfirmModalState();
}

class MacroEditorConfirmModalState extends State<MacroEditorConfirmModal> {
  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);
    if (kitsuDeck.isConnected) {
      kitsuDeck.stream.firstWhere(
        (event) {
          Map jsonData = jsonDecode(event);
          if (jsonData["event"] == "CREATE_MACRO" &&
              jsonData["status"] == true) {
            Navigator.pop(context, true);
            return true;
          } else if (jsonData["event"] == "CREATE_MACRO" &&
              !jsonData["status"]) {
            SnackBar snackBar = SnackBar(
              content: jsonData["message"],
              duration: const Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context, false);
            return true;
          }
          if (jsonData["event"] == "EDIT_MACRO" && jsonData["status"] == true) {
            Navigator.pop(context, true);
            return true;
          } else if (jsonData["event"] == "UPDATE_MACRO" &&
              !jsonData["status"]) {
            SnackBar snackBar = SnackBar(
              content: jsonData["message"],
              duration: const Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context, false);
            return true;
          }
          if (jsonData["event"] == "DELETE_MACRO" &&
              jsonData["status"] == true) {
            SnackBar snackBar = const SnackBar(
              content: Text("Macro deleted successfully"),
              duration: Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context, true);
            return true;
          } else if (jsonData["event"] == "DELETE_MACRO" &&
              !jsonData["status"]) {
            SnackBar snackBar = SnackBar(
              content: jsonData["message"],
              duration: const Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context, false);
            return true;
          }

          return false;
        },
      );
    }

    String title = widget.isEditingMode ? "Update Macro?" : "Add Macro?";
    if (widget.isDeleteMode != null && widget.isDeleteMode!) {
      title = "Delete Macro?";
    }

    return AlertDialog(
      title: Text(title,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      content: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.macroImageData["image_widget"] != null)
              widget.macroImageData["image_widget"],
            if (widget.macroImageData["image_widget"] == null)
              // load image from assets
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  "assets/images/macro_icon.jpg", // "assets/images/app_icon.png
                  width: 100,
                  height: 100,
                ),
              ),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.macroName,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                    Text(widget.macroDescription)
                  ],
                )),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Macro from left to right:", style: TextStyle(fontSize: 20)),
        Expanded(
            child: Wrap(
          children: [
            for (var index = 0; index < widget.macroRecording.length; index++)
              Container(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                  ),
                  onPressed: null,
                  child: Text(
                    widget.macroRecording[index]["keyLabel"],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
          ],
        )),
        // here maybe add a test btn that will run the macro
      ]),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No")),
        TextButton(
            onPressed: () {
              // send a macro creation event to the server
              if (widget.isDeleteMode != null && widget.isDeleteMode!) {
                Map jsonData = {
                  "event": "DELETE_MACRO",
                  "auth_pin": kitsuDeck.pin,
                  "macro_id": widget.macroId
                };
                kitsuDeck.send(jsonEncode(jsonData));
                return;
              } else {
                Map jsonData = {
                  "event": widget.isEditingMode ? "EDIT_MACRO" : "CREATE_MACRO",
                  "auth_pin": kitsuDeck.pin,
                  "macro_name": widget.macroName,
                  "macro_description": widget.macroDescription,
                  "macro_action": {
                    "type": widget.macroAction,
                    "action": widget.macroRecording
                  },
                  "macro_image_id": widget.isEditingMode
                      ? widget.imageId
                      : widget.macroImageData["id"]
                };
                if (widget.isEditingMode) {
                  jsonData["macro_id"] = widget.macroId;
                }
                if (widget.macroImageData["id"] != null &&
                    widget.macroImageData.isNotEmpty &&
                    widget.isEditingMode) {
                  jsonData["macro_image_id"] = widget.macroImageData["id"];
                }
                kitsuDeck.send(jsonEncode(jsonData));
              }
            },
            child: const Text("Yes")),
      ],
    );
  }
}

Future<bool?> showMacroEditorConfirmModal(
    BuildContext context,
    int macroAction,
    String name,
    String macroDescription,
    List<dynamic> macroRecording,
    Map<dynamic, dynamic> image,
    bool isEditingMode,
    [String? macroId,
    String? imageId,
    bool? isDeleteMode]) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return MacroEditorConfirmModal(
        macroAction: macroAction,
        macroName: name,
        macroDescription: macroDescription,
        macroRecording: macroRecording,
        macroImageData: image,
        isEditingMode: isEditingMode,
        macroId: macroId,
        imageId: imageId,
        isDeleteMode: isDeleteMode,
      );
    },
  );
}
