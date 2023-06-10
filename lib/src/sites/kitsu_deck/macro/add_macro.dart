import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitsu_deck_dash/src/sites/kitsu_deck/macro/macro_images.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../classes/websocket/connector.dart';

const List<String> macroActions = <String>["Macro"];

// macro Types definitions, is used in the deck to know what type of macro it is
int macroAction = 0; // macro = keyboard key emulation (Hello world)
int fnAction = 1; // fn = function key emulation (F1-F...)
int programAction = 2; // program = open program (Open Chrome)

class AddMacroModal extends StatefulWidget {
  final String? macroId;
  final String? macroName;
  final String? macroDescription;
  final List? macroRecording;
  final int? macroType;
  final Widget? imageData;
  final String? imageId;

  const AddMacroModal(
      {super.key,
      this.macroId,
      this.macroName,
      this.macroDescription,
      this.macroRecording,
      this.macroType,
      this.imageData,
      this.imageId});

  @override
  AddMacroModalState createState() => AddMacroModalState();
}

class AddMacroModalState extends State<AddMacroModal> {
  // init state if macro is being edited
  bool isEditingMode = false;
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
      macroRecording = widget.macroRecording!;
    }
    if (widget.macroType != null) {
      macroAction = widget.macroType!;
    }
    if (widget.imageData != null) {
      _imageReturn = {"image": widget.imageData!};
    }
  }

  Map _imageReturn = {};
  int macroActionsValue = 0;
  bool isMacroRecording = false;
  List macroRecording = [];

  TextEditingController macroNameController = TextEditingController();
  TextEditingController macroDescriptionController = TextEditingController();
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
                            if (isMacroRecording) {
                              RawKeyboard.instance
                                  .removeListener(_handleKeyDownEvent);
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
                                          _imageReturn = imageData!;
                                        });
                                      }),
                                )
                              } else ...{
                                SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: _imageReturn["image"]),
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
                        child:
                            Text(value, style: const TextStyle(fontSize: 20)),
                      );
                    }).toList(),
                  ),
                  if (macroActionsValue == macroAction) ...{
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
                                  if (isEditingMode)
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () async {
                                            // remove the listener for the macro recording
                                            RawKeyboard.instance.removeListener(
                                                _handleKeyDownEvent);
                                            setState(() {
                                              isMacroRecording = false;
                                            });
                                            // check if the macro is empty
                                            if (macroRecording.isEmpty) {
                                              const snackBar = SnackBar(
                                                content: Text(
                                                    "Please record a macro"),
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
                                            if (macroRecording.isNotEmpty &&
                                                macroNameController
                                                    .text.isNotEmpty) {
                                              print(widget.imageId);
                                              // save the macro
                                              bool? result =
                                                  await showAddMacroConfirmModal(
                                                context,
                                                macroActionsValue,
                                                macroNameController.text,
                                                macroDescriptionController.text,
                                                macroRecording,
                                                _imageReturn,
                                                isEditingMode,
                                                widget.macroId,
                                                widget.imageId,
                                              );
                                              if (result != null &&
                                                  result == true) {
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
                                    ),
                                  if (!isEditingMode)
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () async {
                                            // remove the listener for the macro recording
                                            RawKeyboard.instance.removeListener(
                                                _handleKeyDownEvent);
                                            setState(() {
                                              isMacroRecording = false;
                                            });
                                            // check if the macro is empty
                                            if (macroRecording.isEmpty) {
                                              const snackBar = SnackBar(
                                                content: Text(
                                                    "Please record a macro"),
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
                                            if (macroRecording.isNotEmpty &&
                                                macroNameController
                                                    .text.isNotEmpty) {
                                              // save the macro
                                              bool? result =
                                                  await showAddMacroConfirmModal(
                                                context,
                                                macroActionsValue,
                                                macroNameController.text,
                                                macroDescriptionController.text,
                                                macroRecording,
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

Future<bool?> showMacroModal(BuildContext context,
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
      return AddMacroModal(
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

class AddMacroConfirmModal extends StatefulWidget {
  final String? macroId;
  final int macroAction;
  final String macroName;
  final String macroDescription;
  final List<dynamic> macroRecording;
  final Map<dynamic, dynamic> macroImageData;
  final bool isEditingMode;
  final String? imageId;
  AddMacroConfirmModal(
      {super.key,
      required this.macroAction,
      required this.macroName,
      required this.macroDescription,
      required this.macroRecording,
      required this.macroImageData,
      required this.isEditingMode,
      this.macroId,
      this.imageId});

  @override
  AddMacroConfirmModalState createState() => AddMacroConfirmModalState();
}

class AddMacroConfirmModalState extends State<AddMacroConfirmModal> {
  @override
  Widget build(BuildContext context) {
    final websocket = Provider.of<DeckWebsocket>(context);
    if (websocket.isConnected) {
      websocket.stream.firstWhere(
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
          return false;
        },
      );
    }
    return AlertDialog(
      title: Text(widget.isEditingMode ? "Update Macro?" : "Add Macro?",
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      content: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.macroImageData["image"] != null)
              widget.macroImageData["image"],
            if (widget.macroImageData["image"] == null)
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
                    widget.macroRecording[index]["key"],
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
              print(widget.macroImageData.toString());
              // send a macro creation event to the server
              Map jsonData = {
                "event": widget.isEditingMode ? "EDIT_MACRO" : "CREATE_MACRO",
                "auth_pin": websocket.pin,
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
              if (widget.macroImageData.isNotEmpty) {
                jsonData["macro_image_id"] = widget.macroImageData["id"];
              }
              websocket.send(jsonEncode(jsonData));
            },
            child: const Text("Yes")),
      ],
    );
  }
}

Future<bool?> showAddMacroConfirmModal(
    BuildContext context,
    int macroAction,
    String name,
    String macroDescription,
    List<dynamic> macroRecording,
    Map<dynamic, dynamic> image,
    bool isEditingMode,
    [String? macroId,
    String? imageId]) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return AddMacroConfirmModal(
        macroAction: macroAction,
        macroName: name,
        macroDescription: macroDescription,
        macroRecording: macroRecording,
        macroImageData: image,
        isEditingMode: isEditingMode,
        macroId: macroId,
        imageId: imageId,
      );
    },
  );
}
