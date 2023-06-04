import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crop_image/crop_image.dart';

import '../../../classes/kitsu_deck/device.dart';
import '../../../classes/websocket/connector.dart';
import '../../../helper/network.dart';

class MacroImagesModal extends StatefulWidget {
  const MacroImagesModal({super.key});

  @override
  MacroImagesModalState createState() => MacroImagesModalState();
}

class MacroImagesModalState extends State<MacroImagesModal> {
  // logic stuff
  bool _isLoaded = false;
  bool _isLoading = false;

  List _kitsuDeckMacroImages = [];
  Map _imageB64Return = {};
  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);
    if (!_isLoading && !_isLoaded) {
      _isLoading = true;
      websocket.send(
        jsonEncode(
          {"event": "GET_MACRO_IMAGES", "auth_pin": websocket.pin},
        ),
      );
      websocket.stream.firstWhere((event) {
        Map jsonData = jsonDecode(event);
        if (jsonData["event"] == "GET_MACRO_IMAGES") {
          setState(() {
            _isLoaded = true;
            _isLoading = false;
            if (jsonData["images"] != null) {
              for (var image in jsonData["images"]) {
                getMacroImage(kitsuDeck.ip, websocket.pin, image["name"])
                    .then((value) {
                  var imageData = Image.memory(
                    value,
                    fit: BoxFit.cover,
                  );
                  setState(() {
                    _kitsuDeckMacroImages.add({
                      "id": image["id"],
                      "name": image["name"],
                      "image": imageData,
                    });
                  });
                });
              }
            }
          });
          return true;
        }
        return false;
      });
    }
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
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    Theme.of(context).primaryColor.withOpacity(0.6),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context, {});
                            },
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            )),
                      ),
                      Expanded(
                        child: DragToMoveArea(
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: const [
                                  Spacer(),
                                  Text(
                                    "Macro images",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var image in _kitsuDeckMacroImages) ...{
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: _imageB64Return["id"] == image["id"]
                            ? Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 5,
                              )
                            : Border.all(
                                color: Colors.transparent,
                                width: 5,
                              ),
                      ),
                      child: InkWell(
                          child: image["image"],
                          onTap: () {
                            setState(() {
                              _imageB64Return = image;
                            });
                          }),
                    )
                  },
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showMacroImagesUploadModal(context);
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary),
                          child: const Text("Upload"),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, _imageB64Return);
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green),
                          child: const Text("Select"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<Map?> showMacroImagesModal(BuildContext context) async {
  return await showGeneralDialog<Map>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const MacroImagesModal();
    },
  );
}

class MacroImagesUploadModal extends StatefulWidget {
  const MacroImagesUploadModal({super.key});

  @override
  MacroImagesUploadModalState createState() => MacroImagesUploadModalState();
}

class MacroImagesUploadModalState extends State<MacroImagesUploadModal> {
  var _image;

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
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: DragToMoveArea(
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: const [
                                  Spacer(),
                                  Text(
                                    "Upload macro image",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        // make border gradient
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                        width: 5,
                      ),
                    ),
                    child: _image != null
                        ? Image(
                            image: _image,
                          )
                        : InkWell(
                            onTap: () async {
                              // open file picker
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'png', 'bmp'],
                              );
                              if (result != null) {
                                setState(() {
                                  _image = File(result.files.single.path!);
                                });
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: const Icon(
                              Icons.upload_file,
                              size: 75,
                            ),
                          ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _image != null
                              ? () async {
                                  // upload image
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          child: const Text("Upload"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> showMacroImagesUploadModal(BuildContext context) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return MacroImagesUploadModal();
    },
  );
}
