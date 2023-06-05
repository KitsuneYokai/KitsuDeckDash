import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.4),
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
                                  print(upload);
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
              // TODO: add more image formats (final supported formats: jpg, png, bmp and maybe gif)
              // generate random filename it should be numbers and letters and not datetime
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
