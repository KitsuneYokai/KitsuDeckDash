import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// define folder paths
const String kitsuDeckDir = "KitsuDeckDash/";
const String kitsuDeckLogDir = "${kitsuDeckDir}Log/";

Future<String> createOrReturnFolderInAppDocDir(String folderName) async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String folderPath = join(appDocDir.path, folderName);

  final Directory appDocDirFolder = Directory(folderPath);

  if (await appDocDirFolder.exists()) {
    return appDocDirFolder.path;
  } else {
    final Directory appDocDirNewFolder =
        await appDocDirFolder.create(recursive: true);
    return appDocDirNewFolder.path;
  }
}

Future<String> getAppDocDir() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  return "${appDocDir.path}/$kitsuDeckDir";
}

Future<String> getLogFolder() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String folderPath = join(appDocDir.path, kitsuDeckLogDir);

  final Directory appDocDirFolder = Directory(folderPath);

  if (await appDocDirFolder.exists()) {
    return appDocDirFolder.path;
  } else {
    final Directory appDocDirNewFolder =
        await appDocDirFolder.create(recursive: true);
    return appDocDirNewFolder.path;
  }
}
