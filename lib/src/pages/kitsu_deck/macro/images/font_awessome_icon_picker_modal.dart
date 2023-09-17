import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Font awesome file picker
class FontAwesomeIconPickerModal extends StatefulWidget {
  const FontAwesomeIconPickerModal({super.key});

  @override
  FontAwesomeIconPickerModalState createState() =>
      FontAwesomeIconPickerModalState();
}

class FontAwesomeIconPickerModalState
    extends State<FontAwesomeIconPickerModal> {
  late List<Map<String, dynamic>> fontAwesomeIcons;

  @override
  Widget build(BuildContext context) {
    // Todo: make it load in chunks so it doesn't take so long to load (2025 images takes around 20 sek on RyZen 5800x3d)
    convertSVGPathToImage(String rawSvgPath, width, height) async {
      final PictureInfo pictureInfo =
          await vg.loadPicture(SvgStringLoader(rawSvgPath), context);
      // look what number is the highest in width and height and use that number for the image size and align the image in the middle
      if (width > height) {
        height = width;
      } else {
        width = height;
      }
      final image = pictureInfo.picture.toImageSync(width, height);
      return image;
    }

    imageToBytes(image) async {
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List u8Image = bytes.buffer.asUint8List();
      return u8Image;
    }

    Future<List<Map<String, dynamic>>> loadFontAwesomeJson() async {
      return await rootBundle.loadStructuredData(
          'assets/font-awesome-icons.json', (jsonStr) async {
        Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
        // create a new better list for the icons
        final List<Map<String, dynamic>> icons = [];
        for (var icon in jsonMap.keys) {
          if (jsonMap[icon]["svg"]["solid"] != null) {
            var image = await convertSVGPathToImage(
                jsonMap[icon]["svg"]["solid"]["raw"].toString(),
                jsonMap[icon]["svg"]["solid"]["width"],
                jsonMap[icon]["svg"]["solid"]["height"]);

            icons.add({
              "name": "$icon-solid",
              "image": Image.memory(await imageToBytes(image)),
              "file": image,
            });
          }
          if (jsonMap[icon]["svg"]["regular"] != null) {
            var image = await convertSVGPathToImage(
                jsonMap[icon]["svg"]["regular"]["raw"].toString(),
                jsonMap[icon]["svg"]["regular"]["width"],
                jsonMap[icon]["svg"]["regular"]["height"]);

            icons.add({
              "name": "$icon-regular",
              "image": Image.memory(await imageToBytes(image)),
              "file": image,
            });
          }
          if (jsonMap[icon]["svg"]["brands"] != null) {
            var image = await convertSVGPathToImage(
                jsonMap[icon]["svg"]["brands"]["raw"].toString(),
                jsonMap[icon]["svg"]["brands"]["width"],
                jsonMap[icon]["svg"]["brands"]["height"]);

            icons.add({
              "name": "$icon-brands",
              "image": Image.memory(await imageToBytes(image)),
              "file": image,
            });
          }
        }
        setState(() {
          fontAwesomeIcons = icons;
        });
        return icons;
      });
    }

    return AlertDialog(
        content: FutureBuilder(
            future: loadFontAwesomeJson(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runSpacing: 20,
                  spacing: 20,
                  children: [
                    for (var icon in snapshot.data!) ...{
                      icon["image"] != null
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(context, icon["image"]);
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    // make border gradient
                                    color: Colors.grey[400]!,
                                    width: 5,
                                  ),
                                ),
                                child: icon["image"],
                              ),
                            )
                          : const SizedBox(),
                    }
                  ],
                ));
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            })));
  }
}

Future showFontAwesomeIconPickerModal(BuildContext context) async {
  return await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const FontAwesomeIconPickerModal();
    },
  );
}
