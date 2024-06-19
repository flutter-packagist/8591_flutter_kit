import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class CustomOutput extends LogOutput {
  IOSink? _sink;
  Completer<void> completer = Completer();

  @override
  Future<void> init() async {
    if (!kIsWeb) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      DateTime dateTime = DateTime.now();
      String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
      String path = '${appDocDir.path}${Platform.pathSeparator}log'
          '${Platform.pathSeparator}$date.txt';
      File file = File(path);
      if (!file.existsSync()) await file.create(recursive: true);
      _sink = file.openWrite(mode: FileMode.append, encoding: utf8);
    }
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  @override
  void output(OutputEvent event) async {
    if (!completer.isCompleted) {
      await completer.future;
    }
    // 输出log到控制台
    // ignore: avoid_print
    if (!kReleaseMode) event.lines.forEach(print);
    // 输出log到文件
    var lines = event.lines.map((line) {
      return line
          .replaceAll("[38;5;12m", "")
          .replaceAll("[38;5;196m", "")
          .replaceAll("[38;5;35m", "")
          .replaceAll("[38;5;208m", "")
          .replaceAll("[38;5;244m", "")
          .replaceAll("[38;5;250m", "")
          .replaceAll("[48;5;12m", "")
          .replaceAll("[48;5;196m", "")
          .replaceAll("[48;5;35m", "")
          .replaceAll("[48;5;208m", "")
          .replaceAll("[48;5;244m", "")
          .replaceAll("[48;5;250m", "")
          .replaceAll("[0m", "")
          .replaceAll("[39m", "")
          .replaceAll("[49m", "")
          .replaceAll("", "");
    }).toList();
    _sink?.writeAll(lines, '\n');
    _sink?.writeln();
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
