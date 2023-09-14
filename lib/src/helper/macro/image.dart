import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kitsu_deck_dash/src/helper/network.dart';
import 'package:image/image.dart' as IMG;

Future<void> fetchMacroData(sink, websocketPin) async {
  sink.add(jsonEncode({"event": "GET_MACROS", "auth_pin": websocketPin}));
  sink.add(jsonEncode({"event": "GET_MACRO_IMAGES", "auth_pin": websocketPin}));
}

Future combineData(macroData, ImageData) async {
  // create the image_widget json object for each macro
  for (var macro in macroData) {
    for (var image in ImageData) {
      if (macro["image"] == image["id"]) {
        macro["image_widget"] = image["image"];
      }
    }
  }
  for (macroData in macroData) {
    if (macroData["image_widget"] == null) {
      // create the filler widget if no image is found
      macroData["image_widget"] = ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.asset(
          "assets/images/macro_icon.jpg",
          fit: BoxFit.cover,
        ),
      );
    }
  }
  return macroData;
}

Future fetchImage(ip, pin, kitsuDeckMacroData, kitsuDeckMacroImages) async {
  var finalImages = [];

  for (var image in kitsuDeckMacroImages) {
    var imageData = await getMacroImage(ip, pin, image["name"]);
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
    finalImages.add({
      "id": image["id"],
      "name": image["name"],
      "image": imageData,
    });
  }
  var newFinalImages = await combineData(kitsuDeckMacroData, finalImages);
  return newFinalImages;
}
