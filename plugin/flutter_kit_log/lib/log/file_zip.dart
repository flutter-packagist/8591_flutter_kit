import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class FileZip {
  static Future<void> zipLog() async {
    var encoder = ZipFileEncoder();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = '${appDocDir.path}${Platform.pathSeparator}log';
    encoder.zipDirectory(Directory(appDocPath), filename: "$appDocPath.zip");
    encoder.close();
  }
}
