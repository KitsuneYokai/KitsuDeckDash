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

Future<void> writeLogToFile(dynamic newData, String logFilePath) async {
  File logFile = File(logFilePath);

  if (!await logFile.exists()) {
    await logFile.create(recursive: true);
    await logFile.writeAsString('[]');
  }

  String logFileContent = await logFile.readAsString();
  List<dynamic> logFileContentJson = jsonDecode(logFileContent);
  logFileContentJson.add(newData);
  await logFile.writeAsString(jsonEncode(logFileContentJson));
}

Future<void> cleanUpLogFiles() async {
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
