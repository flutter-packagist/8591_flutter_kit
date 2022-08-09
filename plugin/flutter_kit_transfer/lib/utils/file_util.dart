import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_transfer/platform/platform.dart';
import 'package:path/path.dart';

import '../config/config.dart';
import '../platform/runtime_environment.dart';

enum FlashMemoryCell { bit, kb, mb, gb, tb }

class FileUtil {
  FileUtil._();

  /// 解压Web资源包
  static Future<void> unpackWebResource({String? resourcePath}) async {
    if (GetPlatform.isWeb) return;
    ByteData byteData = await rootBundle.load(
      resourcePath ?? 'packages/${Config.flutterPackage}/assets/web.zip',
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

  /// 获得一个可安全保存的文件路径，如果已经有一个存在了，会在文件名后面添加一个别名
  static String getSafePath(String savePath) {
    if (!File(savePath).existsSync()) {
      return savePath;
    }
    String dirPath = dirname(savePath);
    String fileNameWithoutExt = basenameWithoutExtension(savePath);
    int count = 1;
    String newPath =
        '$dirPath/$fileNameWithoutExt($count)${extension(savePath)}';
    while (File(newPath).existsSync()) {
      count++;
      newPath = '$dirPath/$fileNameWithoutExt($count)${extension(savePath)}';
    }
    return newPath;
  }

  /// 将int的字节长度装换为可读的字符串
  static String? getFileSize(
    int size, [
    FlashMemoryCell flashMemoryCell = FlashMemoryCell.bit,
  ]) {
    String? human;
    if (size < 1024 || flashMemoryCell == FlashMemoryCell.bit) {
      human = '${size}Byte';
    } else if (size >= 1024 && size < pow(1024, 2) ||
        flashMemoryCell == FlashMemoryCell.kb) {
      size = (size / 10.24).round();
      human = '${size / 100}K';
    } else if (size >= pow(1024, 2) && size < pow(1024, 3) ||
        flashMemoryCell == FlashMemoryCell.mb) {
      size = (size / (pow(1024, 2) * 0.01)).round();
      human = '${size / 100}MB';
    } else if (size >= pow(1024, 3) && size < pow(1024, 4)) {
      size = (size / (pow(1024, 3) * 0.01)).round();
      human = '${size / 100}GB';
    }
    return human;
  }

  static String? getFileSizeFromStr(String str) {
    int size = int.tryParse(str)!;
    String? human;
    if (size < 1024) {
      human = '${size}Byte';
    } else if (size >= 1024 && size < pow(1024, 2)) {
      size = (size / 10.24).round();
      human = '${size / 100}k';
    } else if (size >= pow(1024, 2) && size < pow(1024, 3)) {
      size = (size / (pow(1024, 2) * 0.01)).round();
      human = '${size / 100}MB';
    } else if (size >= pow(1024, 3) && size < pow(1024, 4)) {
      size = (size / (pow(1024, 3) * 0.01)).round();
      human = '${size / 100}GB';
    }
    return human;
  }
}
