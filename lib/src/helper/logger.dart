import 'dart:io';
import 'dart:convert';
import './folder.dart';
import 'package:path/path.dart';

Future<String> createLogFile() async {
  DateTime now = DateTime.now();
  String logDir = await createOrReturnFolderInAppDocDir(
      "KitsuDeckDash/Log/${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}");
  String logFileName =
      "$logDir/${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}.json";
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
