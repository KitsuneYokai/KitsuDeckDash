import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../classes/kitsu_deck/device.dart';
import '../../../classes/websocket/connector.dart';

class MacroImagesModal extends StatefulWidget {
  const MacroImagesModal({super.key});

  @override
  MacroImagesModalState createState() => MacroImagesModalState();
}

class MacroImagesModalState extends State<MacroImagesModal> {
  // the return b64 image string from the image picker
  Map _imageB64Return = {};

  // logic stuff
  bool _isLoaded = false;
  bool _isLoading = false;

  List _kitsuDeckMacroImages = [];
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
            _kitsuDeckMacroImages = jsonData["images"];
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
                              Navigator.pop(context, _imageB64Return);
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
                                    "Select an image",
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
                    InkWell(
                      child: Image.memory(base64Decode(image["image"])),
                      onTap: () {
                        _imageB64Return = image;
                        Navigator.pop(context, _imageB64Return);
                      },
                    )
                  }
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
