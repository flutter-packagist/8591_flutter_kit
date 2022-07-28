import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

import '../config/config.dart';
import '../platform/runtime_environment.dart';

class FileUtil {
  FileUtil._();

  /// 解压Web资源包
  Future<void> unpackWebResource() async {
    ByteData byteData = await rootBundle.load(
      '${Config.flutterPackage}assets/web.zip',
    );
    final Uint8List list = byteData.buffer.asUint8List();
    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(list);
    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File wFile = File('${RuntimeEnv.filesPath}/$filename');
        await wFile.create(recursive: true);
        await wFile.writeAsBytes(data);
      } else {
        await Directory('${RuntimeEnv.filesPath}/$filename')
            .create(recursive: true);
      }
    }
  }
}
