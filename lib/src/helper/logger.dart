import 'dart:io';
import 'dart:convert';
import 'package:kitsu_deck_dash/src/helper/folder.dart';
import 'package:path/path.dart';

Future<String> createLogFile() async {
  String logDir = await createOrReturnFolderInAppDocDir(
      "KitsuDeckDash/Log/${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");
  String logFileName =
      "$logDir/${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.json";
  File(logFileName).create(recursive: true);

  return logFileName;
}

writeLogToFile(dynamic newData, String logFilePath) {
  File logFile = File(logFilePath);

  if (!logFile.existsSync()) {
    logFile.createSync(recursive: true);
    logFile.writeAsStringSync(jsonEncode([]));
  }

  String logFileContent = logFile.readAsStringSync();
  List<dynamic> logFileContentJson = jsonDecode(logFileContent);
  logFileContentJson.add(newData);
  logFile.writeAsStringSync(jsonEncode(logFileContentJson));
}

cleanUpLogFiles() async {
  String logFolder = await getLogFolder();
  // delete all logs older than 7 days
  //TODO: make this configurable
  DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  Directory(logFolder)
      .list(recursive: false, followLinks: false)
      .listen((FileSystemEntity entity) {
    if (entity is File) {
      DateTime fileDate = DateTime.parse(basenameWithoutExtension(entity.path));
      if (fileDate.isBefore(sevenDaysAgo)) {
        entity.delete();
      }
    }
  });
}
