import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../helper/logger.dart';
import '../../helper/settings_storage.dart';

// Define enum for log types
enum LogType { info, warning, error }

class KitsuDeck extends ChangeNotifier {
  late String _hostname;
  late String _ip;
  late String _pin;

  bool _isMacroDataLoaded = false;
  List _macroData = [];

  bool _isMacroImagesLoaded = false;
  List _macroImages = [];

  final List<Map> _logList = [];
  late String _logFile;

  // --- getter functions ---
  get hostname => _hostname;
  get ip => _ip;
  get pin => _pin;

  List get macroData => _macroData;
  bool get isMacroDataLoaded => _isMacroDataLoaded;

  bool get isMacroImagesLoaded => _isMacroImagesLoaded;
  List get macroImages => _macroImages;

  List<Map> get logList => _logList;

  // --- setter functions ---
  void setPin(String pin) {
    _pin = pin;
    notifyListeners();
  }

  initKitsuDeckSettings() async {
    // init the log file
    await cleanUpLogFiles();
    _logFile = await createLogFile();
    log("CLEANED OLD LOG FILES 🧹");

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
  }

  // logging function
  void log(String message, [LogType logType = LogType.info]) {
    DateTime dateTime = DateTime.now();
    Map messageMap = {
      "time":
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}",
      "message": message.toString().replaceAll("\n", "").replaceAll("\r", ""),
      "type": logType.toString().split(".")[1]
    };
    writeLogToFile(messageMap, _logFile);
    if (kDebugMode) print(messageMap);
    logList.add(messageMap);
    notify();
  }

  notify() {
    notifyListeners();
  }
}
