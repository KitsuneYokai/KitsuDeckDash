import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:image/image.dart' as IMG;

import '../../../classes/kitsu_deck/device.dart';
import '../../../classes/websocket/connector.dart';
import '../../../helper/network.dart';
import 'add_macro.dart';
import 'macro_images.dart';
import 'macro_layout.dart';

class MacroDashboard extends StatefulWidget {
  const MacroDashboard({super.key});

  @override
  MacroDashboardState createState() => MacroDashboardState();
}

class MacroDashboardState extends State<MacroDashboard> {
  bool isSent = false;

  bool isMacroLoaded = false;
  List macroData = [];

  bool isMacroImageLoaded = false;
  List kitsuDeckMacroImages = [];

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
      websocket.stream.listen((event) {
        Map jsonData = jsonDecode(event);
        // handle macros
        if (jsonData["event"] == "GET_MACROS" && !isMacroLoaded) {
          macroData += jsonData["macros"];
          if (jsonData["status"] == true && mounted) {
            setState(() {
              isMacroLoaded = true;
            });
          }
        }
        // handle macro images
        if (jsonData["event"] == "GET_MACRO_IMAGES" && !isMacroImageLoaded) {
          kitsuDeckMacroImages.clear();

          for (var image in jsonData["images"]) {
            // delay loading of next image
            Future.delayed(const Duration(seconds: 1), () async {
              var imageData = await getMacroImage(
                  kitsuDeck.ip, websocket.pin, image["name"]);
              // make a image with rounded corners
              if (imageData == null || imageData == false) {
                // create a empty image
                imageData = IMG.Image(width: 100, height: 100);
                IMG.fill(imageData, color: IMG.ColorInt16(0x000000));
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
                setState(() {
                  kitsuDeckMacroImages.add({
                    "id": image["id"],
                    "name": image["name"],
                    "image": imageData,
                  });
                });
              }
            });
            if (mounted) {
              setState(() {
                isMacroImageLoaded = true;
              });
            }
          }
        }
      });
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
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Search Macro',
                                  ),
                                  onChanged: null, //TODO; search macro
                                ),
                                const SizedBox(height: 10),
                                // stream builder with the websocket stream

                                Expanded(
                                    child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (var macro in macroData)
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          onTap: () {
                                            // TODO: open macro editor
                                          },
                                          child: Stack(children: [
                                            Column(
                                              children: [
                                                if (macro["image"] == null ||
                                                    macro["image"] ==
                                                        null.toString()) ...{
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.asset(
                                                      "assets/images/macro_icon.jpg",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                } else ...{
                                                  if (kitsuDeckMacroImages
                                                      .isNotEmpty) ...{
                                                    for (var image
                                                        in kitsuDeckMacroImages)
                                                      if (image["id"] ==
                                                          macro["image"]) ...{
                                                        image["image"]
                                                      }
                                                  } else ...{
                                                    const SizedBox(
                                                        width: 100,
                                                        height: 100,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()))
                                                  }
                                                },
                                              ],
                                            ),
                                            // TODO: add tooltip
                                            Positioned(
                                                bottom: 0,
                                                child: Container(
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    macro["name"],
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ))
                                          ]),
                                        )
                                    ],
                                  ),
                                ))
                              ],
                            ))),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () async {
                                kitsuDeckMacroImages.clear();
                                bool? result = await showMacroModal(context);
                                if (result! == true) {
                                  SnackBar snackBar = const SnackBar(
                                    content: Text("Macro added!"),
                                    duration: Duration(seconds: 3),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  setState(() {
                                    macroData.clear();
                                    isMacroImageLoaded = false;
                                    isMacroLoaded = false;
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
                                setState(() {
                                  macroData.clear();
                                  isMacroImageLoaded = false;
                                  isMacroLoaded = false;
                                  isSent = false;
                                });
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
