import 'dart:io';
import 'dart:convert';

import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

import '../../../helper/apiRequests/kitsuDeck/kitsuDeck.dart';
import 'Makros.dart';

class MacroAddBottomSheet extends StatefulWidget {
  final String hostname;
  final String title;

  MacroAddBottomSheet({required this.hostname, required this.title});

  @override
  _MacroAddBottomSheetState createState() => _MacroAddBottomSheetState();
}

class _MacroAddBottomSheetState extends State<MacroAddBottomSheet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  var macroImg = Image.asset('assets/images/MacroIcon.png');
  var macroImgBytes = Uint8List(0);

  var selectedTypeValue = 0;

  bool isRecordingMacro = false;
  List macroRecording = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void _handleKeyDownEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // if keys are pressed down then add them to the macroRecording list
      setState(() {
        var key = event.logicalKey.keyLabel;
        var code = event.logicalKey.keyId;
        if (key == " ") {
          key = "Space";
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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: 20,
            left: 10,
            child: FloatingActionButton(
              heroTag: "close",
              onPressed: () {
                if (isRecordingMacro) {
                  RawKeyboard.instance.removeListener(_handleKeyDownEvent);
                }
                Navigator.pop(context);
              },
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 40,
            child: FloatingActionButton(
                heroTag: "save",
                onPressed: () async {
                  // save the macro
                  if (nameController.text != "") {
                    if (selectedTypeValue == 0) {
                      // if the macro is a macro then send the macroRecording list to the server
                      var response = await addKitsuDeckMacro(
                          widget.hostname,
                          nameController.text,
                          // macro image bytes as base64
                          macroImgBytes.isNotEmpty
                              ? base64Encode(macroImgBytes)
                              : base64Encode((await rootBundle
                                      .load('assets/images/MacroIcon.png'))
                                  .buffer
                                  .asUint8List()),
                          selectedTypeValue,
                          jsonEncode(macroRecording),
                          descriptionController.text);
                      if (jsonDecode(response)["status"]) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KitsuDeckMakros(
                                  KitsuDeckDeviceName: widget.hostname)),
                        );
                      }
                    } else {
                      showAboutDialog(context: context, children: const [
                        Text("This feature is not yet implemented")
                      ]);
                    }
                  }
                },
                child: const Icon(Icons.save, color: Colors.white)),
          ),
        ],
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          DragToMoveArea(
              child: SizedBox(
            height: 40,
            child: Center(
              child: Text(widget.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 60),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Name'),
                      ),
                    ),
                    // the image picker button
                    OutlinedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(0)),
                          minimumSize: MaterialStateProperty.all<Size>(
                              const Size(64, 64)),
                          maximumSize: MaterialStateProperty.all<Size>(
                              const Size(64, 64)),
                        ),
                        onPressed: () {
                          // open the file picker, only allow images to be selected max size 2 mb and max 1 file at a time
                          FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            withData: true,
                            allowedExtensions: ['jpg', 'png', 'jpeg'],
                          ).then((value) {
                            if (value != null) {
                              // if the file is selected, convert the image to max 64x64 and max 2 mb and set the image to the macroImg using Image.memory
                              File file = File(value.files.single.path!);
                              if (file != null) {
                                var imageBytes = file.readAsBytesSync();
                                Image? imageWidget = Image.memory(imageBytes);
                                if (imageWidget != null) {
                                  img.Image image =
                                      img.decodeImage(imageBytes)!;
                                  if (image.width > 64 || image.height > 64) {
                                    image = img.copyResize(image,
                                        width: 64, height: 64);
                                    macroImgBytes = Uint8List.fromList(
                                        img.encodeJpg(image, quality: 100));
                                  }
                                  if (file.lengthSync() > 64 * 64) {
                                    image = img.copyResize(image,
                                        width: 64, height: 64);
                                    // calculate the quality of the image to be max 4 kb
                                    var quality = (256 * 256) /
                                        (file.lengthSync() /
                                            100.roundToDouble());

                                    List<int> encodedImage = img.encodeJpg(
                                        image,
                                        quality: quality.toInt());

                                    macroImgBytes = encodedImage.isNotEmpty
                                        ? Uint8List.fromList(encodedImage)
                                        : Uint8List(0);

                                    imageWidget = Image.memory(
                                        Uint8List.fromList(encodedImage));
                                  }
                                  setState(() {
                                    macroImg = imageWidget as Image;
                                  });
                                }
                              }
                            }
                          });
                        },
                        child: macroImg)
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Type: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton(
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text("Macro"),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text("Function key"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("Open Program"),
                        ),
                      ],
                      onChanged: (value) {
                        //change the value of the dropdown
                        setState(() {
                          selectedTypeValue = value!;
                        });
                      },
                      value: selectedTypeValue,
                    ),
                  ],
                ),
                if (selectedTypeValue == 0) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              macroRecording = [];
                            });
                          },
                          child: const Icon(Icons.delete, color: Colors.white)),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                          ),
                          onPressed: () {
                            if (isRecordingMacro) {
                              RawKeyboard.instance
                                  .removeListener(_handleKeyDownEvent);
                            } else {
                              RawKeyboard.instance
                                  .addListener(_handleKeyDownEvent);
                            }
                            setState(() {
                              isRecordingMacro = !isRecordingMacro;
                            });
                          },
                          child: Builder(builder: (context) {
                            if (isRecordingMacro) {
                              return const Icon(Icons.stop, color: Colors.red);
                            } else {
                              return const Icon(Icons.fiber_manual_record,
                                  color: Colors.green);
                            }
                          })),
                      if (macroRecording != [])
                        // convert the macro key id to a key label
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  for (var i = 0;
                                      i < macroRecording.length;
                                      i++) ...[
                                    if (i != 0)
                                      const Icon(Icons.arrow_right_alt,
                                          color: Colors.white),
                                    Container(
                                      //create a gradient box with rounded corners
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.9),
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.9)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.all(5),
                                      child: Text(macroRecording[i]["key"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ]
                                ]),
                          ),
                        )
                    ],
                  )
                ],
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Description'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
