import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crop_image/crop_image.dart';
import 'package:image/image.dart' as IMG;

import '../../../classes/kitsu_deck/device.dart';
import '../../../classes/websocket/connector.dart';
import '../../../helper/network.dart';

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
          if (jsonData["images"].length > 0) {
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
                    _kitsuDeckMacroImages.add({
                      "id": image["id"],
                      "name": image["name"],
                      "image": imageData,
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
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: _imageB64Return["id"] == image["id"] &&
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
                                child: image["image"],
                                onTap: widget.isSelectable
                                    ? () {
                                        setState(() {
                                          _imageB64Return = image;
                                        });
                                      }
                                    : null,
                              )),
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
                            onPressed: () {
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

class MacroImagesUploadModal extends StatefulWidget {
  const MacroImagesUploadModal({super.key});

  @override
  MacroImagesUploadModalState createState() => MacroImagesUploadModalState();
}

class MacroImagesUploadModalState extends State<MacroImagesUploadModal> {
  var _image;

  var imageCropController;

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
                  if (_image == null) ...{
                    const Spacer(),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          // make border gradient
                          color: Colors.grey[400]!,
                          width: 5,
                        ),
                      ),
                      child: InkWell(
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
                              imageCropController = CropController(
                                aspectRatio: 1,
                                defaultCrop:
                                    const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
                              );
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
                    // ignore: prefer_const_constructors
                    Spacer(),
                  },
                  if (_image != null)
                    Expanded(
                        child: CropImage(
                      image: Image.file(_image),
                      controller: imageCropController,
                      alwaysMove: true,
                    )),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        if (_image != null) ...{
                          TextButton(
                            onPressed: () {
                              imageCropController.rotateRight();
                            },
                            child: const Icon(Icons.rotate_90_degrees_cw),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            child: const Icon(Icons.delete),
                          ),
                        },
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _image != null
                              ? () async {
                                  // crop image
                                  Image croppedImage =
                                      await imageCropController.croppedImage();
                                  var bitmap =
                                      await imageCropController.croppedBitmap();
                                  bool? upload =
                                      await showMacroImagesUploadConfirmModal(
                                          context, croppedImage, bitmap);
                                  if (upload != null && upload) {
                                    Navigator.pop(context, true);
                                  }
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
      return const MacroImagesUploadModal();
    },
  );
}

class MacroImagesUploadConfirmModal extends StatefulWidget {
  final Image croppedImage;
  final bitmap;
  const MacroImagesUploadConfirmModal(
      {super.key, required this.croppedImage, required this.bitmap});

  @override
  MacroImagesUploadConfirmModalState createState() =>
      MacroImagesUploadConfirmModalState();
}

class MacroImagesUploadConfirmModalState
    extends State<MacroImagesUploadConfirmModal> {
  final String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: const Text("Is this the image you want to upload?"),
        content: SizedBox(
          height: 400,
          child: Center(child: Image(image: widget.croppedImage.image)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              // TODO: add more image formats (final supported formats: jpg, png, bmp and maybe gif) also i will check how the .bin files are generated on the LVGL image converter site,
              // TODO: and implement the same thing here, because the .bin files are loaded faster by the LVGL library

              var filename = getRandomString(10);
              // upload to kitsu deck server and close modal with true
              var bitmap = widget.bitmap;
              var imageData =
                  await bitmap.toByteData(format: ImageByteFormat.png);
              var image = IMG.decodeImage(imageData!.buffer.asUint8List());
              // change the image size to 100 x 100
              var thumbnail = IMG.copyResize(image!, width: 100, height: 100);
              var thumbnailImage = IMG.encodeJpg(thumbnail, quality: 100);
              // resize the image if it is too big
              if (thumbnailImage.length > 15000) {
                thumbnailImage = IMG.encodeJpg(thumbnail, quality: 70);
              }
              var thumbnailFile = MultipartFile.fromBytes(
                "image",
                thumbnailImage,
                filename: "$filename.jpg",
              );
              // replace empty pin with NULL so the server knows it is empty
              String websocketPin = websocket.pin.toString();
              if (websocketPin.isEmpty) {
                websocketPin = "NULL";
              }
              bool? upload = await postMacroImage(
                  kitsuDeck.ip, websocketPin, thumbnailFile);

              if (upload == true) {
                Navigator.pop(context, true);
              }
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showMacroImagesUploadConfirmModal(
    BuildContext context, Image croppedImage, bitmap) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return MacroImagesUploadConfirmModal(
          croppedImage: croppedImage, bitmap: bitmap);
    },
  );
}
