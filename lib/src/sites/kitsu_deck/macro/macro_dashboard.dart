import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:image/image.dart' as IMG;

import '../../../classes/kitsu_deck/device.dart';
import '../../../classes/websocket/connector.dart';
import '../../../helper/network.dart';
import 'macro_editor.dart';
import 'macro_images.dart';
import 'macro_layout_editor.dart';

class MacroDashboard extends StatefulWidget {
  const MacroDashboard({super.key});

  @override
  MacroDashboardState createState() => MacroDashboardState();
}

class MacroDashboardState extends State<MacroDashboard> {
  bool isSent = false;

  @override
  Widget build(BuildContext context) {
    final websocket = Provider.of<DeckWebsocket>(context);
    final kitsuDeck = Provider.of<KitsuDeck>(context);

    if (websocket.isConnected && mounted) {
      if (!isSent) {
        websocket.send(
            jsonEncode({"event": "GET_MACROS", "auth_pin": websocket.pin}));
        websocket.send(jsonEncode(
            {"event": "GET_MACRO_IMAGES", "auth_pin": websocket.pin}));
        isSent = true;
      }
    }
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
                      child: StreamBuilder(
                          stream: websocket.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map jsonData =
                                  jsonDecode(snapshot.data.toString());
                              // load macro Data
                              if (jsonData["event"] == "GET_MACROS" &&
                                  !kitsuDeck.isMacroDataLoaded) {
                                List macroData = kitsuDeck.macroData;
                                for (var macro in jsonData["macros"]) {
                                  macroData.add(macro);
                                }
                                if (jsonData["status"] == true) {
                                  kitsuDeck.setIsMacroDataLoaded(true);
                                }
                              }
                              if (jsonData["event"] == "GET_MACRO_IMAGES" &&
                                  !kitsuDeck.isMacroImagesLoaded) {
                                // check if jsonData["images"] is empty
                                if (jsonData["images"].length == 0) {
                                  kitsuDeck.setIsMacroImagesLoaded(true);
                                }
                                for (var image in jsonData["images"]) {
                                  // delay loading of next image
                                  Future.delayed(const Duration(seconds: 1),
                                      () async {
                                    var imageData = await getMacroImage(
                                        kitsuDeck.ip,
                                        websocket.pin,
                                        image["name"]);
                                    // make a image with rounded corners
                                    if (imageData == null ||
                                        imageData == false) {
                                      // create a empty image
                                      imageData =
                                          IMG.Image(width: 100, height: 100);
                                      IMG.fill(imageData,
                                          color: IMG.ColorInt16(0x000000));
                                      imageData = IMG.encodeJpg(imageData);
                                    }
                                    imageData = ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.memory(
                                        imageData,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                    if (mounted) {
                                      List<dynamic> kitsuDeckMacroImages =
                                          kitsuDeck.macroImages;
                                      kitsuDeckMacroImages =
                                          kitsuDeck.macroImages;
                                      kitsuDeckMacroImages.add({
                                        "id": image["id"],
                                        "name": image["name"],
                                        "image": imageData,
                                      });
                                      kitsuDeck
                                          .setMacroImages(kitsuDeckMacroImages);
                                    }
                                  });
                                  if (mounted) {
                                    kitsuDeck.setIsMacroImagesLoaded(true);
                                  }
                                }
                              }
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (var macro in kitsuDeck.macroData)
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(children: [
                                        for (var image
                                            in kitsuDeck.macroImages) ...[
                                          if (image["id"] ==
                                              macro["image"]) ...[
                                            image["image"],
                                          ] else ...[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                "assets/images/macro_icon.jpg",
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ]
                                        ],
                                        if (kitsuDeck.macroImages.isEmpty) ...[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              "assets/images/macro_icon.jpg",
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color:
                                                Colors.black.withOpacity(0.35),
                                          ),
                                          child: InkWell(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              onTap: () async {
                                                await showMacroInfoModal(
                                                    context, macro);
                                              },
                                              child: Center(
                                                child: Text(
                                                  macro["name"],
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )),
                                        ),
                                      ]),
                                    )
                                ],
                              );
                            }
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                Text("Loading Macros...")
                              ],
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () {
                                kitsuDeck.setMacroDataNull();
                                setState(() {
                                  isSent = false;
                                });
                              },
                              child: const Row(children: [
                                Icon(Icons.refresh),
                                Text("Refresh Macros")
                              ])),
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
                                kitsuDeck.setMacroDataNull();
                              },
                              child: const Row(children: [
                                Icon(Icons.image_search_outlined),
                                Text("Macro Images")
                              ])),
                          TextButton(
                              onPressed: kitsuDeck.isMacroImagesLoaded &&
                                      kitsuDeck.isMacroDataLoaded &&
                                      kitsuDeck.macroData.isNotEmpty
                                  ? () {
                                      showMacroLayoutEditorModal(context);
                                    }
                                  : null,
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

class MacroInfoModal extends StatefulWidget {
  final Map macro;
  const MacroInfoModal({super.key, required this.macro});

  @override
  MacroInfoModalState createState() => MacroInfoModalState();
}

class MacroInfoModalState extends State<MacroInfoModal> {
  bool isLoaded = false;
  bool isSent = false;
  Map macroData = {};
  @override
  Widget build(BuildContext context) {
    final websocket = Provider.of<DeckWebsocket>(context);
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    if (websocket.isConnected && !isLoaded && mounted) {
      if (!isSent) {
        websocket.send(jsonEncode({
          "event": "GET_MACRO",
          "auth_pin": websocket.pin,
          "macro_id": widget.macro["id"],
        }));
        setState(() {
          isSent = true;
        });
      }
      websocket.stream.firstWhere((value) {
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
              if (widget.macro["image"] == null ||
                  widget.macro["image"] == null.toString()) ...{
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    "assets/images/macro_icon.jpg",
                    fit: BoxFit.cover,
                  ),
                )
              } else ...{
                if (kitsuDeck.macroImages.isNotEmpty) ...{
                  for (var image in kitsuDeck.macroImages)
                    if (image["id"] == widget.macro["image"]) ...{
                      image["image"]
                    }
                }
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

              for (var img in kitsuDeck.macroImages) {
                if (img["id"] == macroData["image"]) {
                  image = img["image"];
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
