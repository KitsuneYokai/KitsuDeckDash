import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

Future<String> getLogFolder() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String folderPath = join(appDocDir.path, "KitsuDeckDash/Log");

  final Directory appDocDirFolder = Directory(folderPath);

  if (await appDocDirFolder.exists()) {
    return appDocDirFolder.path;
  } else {
    final Directory appDocDirNewFolder =
        await appDocDirFolder.create(recursive: true);
    return appDocDirNewFolder.path;
  }
}
