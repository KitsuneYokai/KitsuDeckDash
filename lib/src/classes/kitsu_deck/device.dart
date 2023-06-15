import 'dart:convert';

import 'package:flutter/material.dart';
import '../../helper/settings_storage.dart';

class KitsuDeck extends ChangeNotifier {
  late String _hostname;
  late String _ip;
  late String _pin;

  bool _isMacroDataLoaded = false;
  List _macroData = [];

  bool _isMacroImagesLoaded = false;
  List _macroImages = [];

  // --- getter functions ---
  get hostname => _hostname;
  get ip => _ip;
  get pin => _pin;

  get macroData => _macroData;
  get isMacroDataLoaded => _isMacroDataLoaded;
  get isMacroImagesLoaded => _isMacroImagesLoaded;
  get macroImages => _macroImages;

  // --- setter functions ---
  void setPin(String pin) {
    _pin = pin;
    notifyListeners();
  }

  initKitsuDeckSettings() async {
    final sharedPref = SharedPref();
    final kitsuDeck = await sharedPref.getKitsuDeck();
    if (kitsuDeck != null) {
      var kitsuDeckJson = jsonDecode(kitsuDeck);
      _hostname = kitsuDeckJson["hostname"];
      _ip = kitsuDeckJson["ip"];
      _pin = kitsuDeckJson["pin"];
    } else {
      _hostname = null.toString();
      _ip = null.toString();
      _pin = null.toString();
    }
    return true;
  }

  setKitsuDeckSettings(hostname, ip, pin) async {
    _hostname = hostname;
    _ip = ip;
    _pin = pin;
    final sharedPref = SharedPref();
    await sharedPref.setKitsuDeck(
      hostname,
      ip,
      pin,
    );
    notifyListeners();
  }

  removeKitsuDeckSettings() async {
    _hostname = null.toString();
    _ip = null.toString();
    _pin = null.toString();
    final sharedPref = SharedPref();
    await sharedPref.removeKitsuDeck();
    notifyListeners();
  }

  setMacroDataNull() {
    _macroImages = [];
    _macroData = [];
    _isMacroDataLoaded = false;
    _isMacroImagesLoaded = false;
    notifyListeners();
  }

  setIsMacroDataLoaded(bool value) {
    _isMacroDataLoaded = value;
  }

  setMacroData(data) {
    _macroData = data;
  }

  setIsMacroImagesLoaded(bool value) {
    _isMacroImagesLoaded = value;
  }

  setMacroImages(data) {
    _macroImages = data;
    notifyListeners();
  }
}
