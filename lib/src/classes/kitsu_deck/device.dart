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
    log("Cleaned up old log files");

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
  void log(String message, [LogType logType = LogType.info]) async {
    Map messageMap = {
      "time":
          "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
      "message": message.toString(),
      "type": logType.toString().split(".")[1]
    };
    await writeLogToFile(messageMap, _logFile);
    // print the message to the console if in debug mode
    if (kDebugMode) print(messageMap);
    // add the message to the log list
    logList.add(messageMap);
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }
}
