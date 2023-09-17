import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kitsu_deck_dash/src/pages/kitsu_deck/macro/images/delete_macro_image_modal.dart';
import 'package:kitsu_deck_dash/src/pages/kitsu_deck/macro/images/macro_image_upload_modal.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:image/image.dart' as IMG;

import '../../../../classes/kitsu_deck/connector.dart';
import '../../../../helper/network.dart';

class MacroImagesModal extends StatefulWidget {
  const MacroImagesModal({super.key, required this.isSelectable});
  final bool isSelectable;

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);

    if (!_isLoading && !_isLoaded) {
      _isLoading = true;
      kitsuDeck.send(
        jsonEncode(
          {"event": "GET_MACRO_IMAGES", "auth_pin": kitsuDeck.pin},
        ),
      );
      kitsuDeck.stream.firstWhere((event) {
        Map jsonData = jsonDecode(event);
        if (jsonData["event"] == "GET_MACRO_IMAGES") {
          if (jsonData["images"].length > 0) {
            for (var image in jsonData["images"]) {
              // delay loading of next image
              Future.delayed(const Duration(seconds: 1), () async {
                var imageData = await getMacroImage(
                    kitsuDeck.ip, kitsuDeck.pin, image["name"]);
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
                    _kitsuDeckMacroImages.add({
                      "id": image["id"],
                      "name": image["name"],
                      "image_widget": imageData,
                    });
                    if (jsonData["images"].indexOf(image) ==
                        jsonData["images"].length - 1) {
                      _isLoaded = true;
                      _isLoading = false;
                    }
                  });
                }
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _isLoaded = true;
                _isLoading = false;
              });
            }
          }
          return true;
        }
        return false;
      });
    }

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
                    const Expanded(
                      child: DragToMoveArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Spacer(),
                                Text(
                                  "Macro Images",
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
                Expanded(
                    child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 10,
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 5,
                            )),
                        child: InkWell(
                          child: const Icon(Icons.add),
                          onTap: () async {
                            _kitsuDeckMacroImages.clear();

                            bool? result =
                                await showMacroImagesUploadModal(context);
                            if (result != null && result) {
                              setState(() {
                                _kitsuDeckMacroImages = [];
                                _isLoaded = false;
                                _isLoading = false;
                              });
                            }
                          },
                        ),
                      ),
                      for (var image in _kitsuDeckMacroImages) ...{
                        Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      _imageB64Return["id"] == image["id"] &&
                                              widget.isSelectable
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 5,
                                            )
                                          : Border.all(
                                              color: Colors.transparent,
                                              width: 5,
                                            ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  child: image["image_widget"],
                                  onTap: widget.isSelectable
                                      ? () {
                                          setState(() {
                                            _imageB64Return = image;
                                          });
                                        }
                                      : null,
                                )),
                            Positioned(
                              right: 5,
                              bottom: 5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(2, 2),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)))),
                                child: const Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                ),
                                onPressed: () async {
                                  bool? result =
                                      await showDeleteMacroImageModal(
                                          context, image);
                                  if (result != null && result) {
                                    setState(() {
                                      _imageB64Return = {};
                                      _kitsuDeckMacroImages = [];
                                      _isLoaded = false;
                                      _isLoading = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      },
                      if (_isLoading) ...{
                        const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      },
                    ],
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      if (widget.isSelectable) ...{
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _imageB64Return.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(context, _imageB64Return);
                                },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green),
                          child: const Text("Select"),
                        ),
                      }
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<Map?> showMacroImagesModal(
    BuildContext context, bool isSelectable) async {
  return await showGeneralDialog<Map>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor:
        isSelectable ? Colors.transparent : Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return MacroImagesModal(isSelectable: isSelectable);
    },
  );
}
