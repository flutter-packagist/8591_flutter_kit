import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';

import '../log/log_data.dart';

const int maxLine = 1000;

class ConsoleManager {
  static final Queue<Tuple2<DateTime, LogData>> _logData = Queue();

  // ignore: close_sinks
  static StreamController? _logStreamController;

  static Queue<Tuple2<DateTime, LogData>> get logData => _logData;

  static StreamController? get streamController => _getLogStreamController();

  static DebugPrintCallback? _originalDebugPrint;

  static StreamController? _getLogStreamController() {
    if (_logStreamController == null) {
      _logStreamController = StreamController.broadcast();
      var transformer =
          StreamTransformer<dynamic, Tuple2<DateTime, LogData>>.fromHandlers(
              handleData: (log, sink) {
        final now = DateTime.now();
        if (log is LogData) {
          sink.add(Tuple2(now, log));
        }
      });

      _logStreamController!.stream.transform(transformer).listen((value) {
        _logData.addFirst(value);
        if (_logData.length > maxLine) {
          _logData.removeLast();
        }
      });
    }
    return _logStreamController;
  }

  static redirectDebugPrint() {
    if (_originalDebugPrint != null) return;
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      ConsoleManager.streamController!.sink.add(message);
      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      }
    };
  }

  static addLog(LogData logData) {
    _logStreamController!.add(logData);
  }

  static clearLog() {
    logData.clear();
    _logStreamController!
        .add(LogData(0, Level.verbose, const TextSpan(text: "Welcome!"), ""));
  }

  @visibleForTesting
  static clearRedirect() {
    debugPrint = _originalDebugPrint!;
    _originalDebugPrint = null;
  }
}
