// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_kit_log/log/log_data.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../console/console_manager.dart';

class CustomOutput extends LogOutput {
  IOSink? _sink;
  int _currentId = 1;
  Completer<void> completer = Completer();

  @override
  void init() async {
    if (kIsWeb) return;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    DateTime dateTime = DateTime.now();
    String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String path = '${appDocDir.path}${Platform.pathSeparator}log'
        '${Platform.pathSeparator}$date.txt';
    File file = File(path);
    if (!file.existsSync()) await file.create(recursive: true);
    _sink = file.openWrite(mode: FileMode.append, encoding: utf8);
    completer.complete();
  }

  @override
  void output(OutputEvent event) async {
    if (!completer.isCompleted) {
      await completer.future;
    }
    // 输出log到控制台
    event.lines.forEach(print);
    // 输出log到手机测试控制台
    var linesText = event.lines.join('\n');
    var logEvent = LogData(
      _currentId++,
      event.level,
      linesText,
      linesText.toLowerCase(),
    );
    ConsoleManager.addLog(logEvent);
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
  void destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
