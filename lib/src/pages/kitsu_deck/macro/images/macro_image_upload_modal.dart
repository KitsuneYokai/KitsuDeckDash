import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kitsu_deck_dash/src/pages/kitsu_deck/macro/images/font_awessome_icon_picker_modal.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crop_image/crop_image.dart';
import 'package:image/image.dart' as IMG;

import '../../../../classes/kitsu_deck/connector.dart';
import '../../../../helper/network.dart';

class MacroImagesUploadModal extends StatefulWidget {
  const MacroImagesUploadModal({super.key});

  @override
  MacroImagesUploadModalState createState() => MacroImagesUploadModalState();
}

class MacroImagesUploadModalState extends State<MacroImagesUploadModal> {
  var _image;

  late CropController imageCropController;

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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (_image == null) ...{
                  const Spacer(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Tooltip(
                          message: "Upload an image from a file",
                          child: Container(
                            width: 150,
                            height: 150,
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
                                  File file = File(result.files.single.path!);
                                  Image image = Image.file(file);
                                  setState(() {
                                    _image = image;
                                    imageCropController = CropController(
                                      aspectRatio: 1,
                                      defaultCrop: const Rect.fromLTRB(
                                          0.1, 0.1, 0.9, 0.9),
                                    );
                                  });
                                }
                              },
                              child: const Icon(
                                Icons.upload_file,
                                size: 75,
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: "Select Font Awesome Icon",
                          child: Container(
                            width: 150,
                            height: 150,
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
                                var result =
                                    await showFontAwesomeIconPickerModal(
                                        context);
                                if (result != null) {
                                  setState(() {
                                    _image = result;
                                    imageCropController = CropController(
                                      aspectRatio: 1,
                                      defaultCrop: const Rect.fromLTRB(
                                          0.1, 0.1, 0.9, 0.9),
                                    );
                                  });
                                }
                              },
                              child: const Icon(
                                Icons.image_search,
                                size: 75,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ignore: prefer_const_constructors
                  Spacer(),
                },
                if (_image != null)
                  Expanded(
                      child: CropImage(
                    image: _image,
                    controller: imageCropController,
                    alwaysMove: false,
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

  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: const Text("Is this the image you want to upload?"),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Center(
            child: Stack(
              children: [
                widget.croppedImage,
                if (_uploading) ...{
                  Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      )),
                }
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _uploading
                ? null
                : () {
                    Navigator.pop(context, false);
                  },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: _uploading
                ? null
                : () async {
                    setState(() {
                      _uploading = true;
                    });
                    // TODO: add more image formats (final supported formats: jpg, png, bmp and maybe gif) also i will check how the .bin files are generated on the LVGL image converter site,
                    // TODO: and implement the same thing here, because the .bin files are loaded faster on the KitsuDeck, cause they dont have to be converted before they are printed on the screen
                    var isJpg = false;

                    var filename = getRandomString(10);
                    // upload to kitsu deck server and close modal with true
                    var bitmap = widget.bitmap;
                    var imageData =
                        await bitmap.toByteData(format: ImageByteFormat.png);
                    var image =
                        IMG.decodeImage(imageData!.buffer.asUint8List());
                    // change the image size to 100 x 100
                    var thumbnail =
                        IMG.copyResize(image!, width: 100, height: 100);
                    var thumbnailImage =
                        IMG.encodePng(thumbnail, singleFrame: true);
                    // reduce the image quality to 50% if the image is bigger than 15000
                    if (thumbnailImage.length > 15000) {
                      thumbnailImage = IMG.encodeJpg(thumbnail, quality: 50);
                      isJpg = true;
                    }
                    var thumbnailFile = MultipartFile.fromBytes(
                      "image",
                      thumbnailImage,
                      filename: "$filename${isJpg ? ".jpg" : ".png"}",
                    );
                    // replace empty pin with NULL so the server knows it is empty
                    String websocketPin = kitsuDeck.pin.toString();
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
    barrierDismissible: false,
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
