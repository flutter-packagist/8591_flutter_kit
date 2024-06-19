import 'package:logger/logger.dart';

import 'custom_filter.dart';
import 'custom_output.dart';
import 'custom_printer.dart';

class LogWrapper {
  LogWrapper._();

  static LogWrapper? _instance;

  factory LogWrapper() => _instance ??= LogWrapper._();

  LogFilter? _logFilter;
  LogOutput? _logOutput;
  Logger? _logger;
  Logger? _loggerBox;
  Logger? _loggerStack;

  set logFilter(LogFilter logFilter) {
    _logFilter = logFilter;
  }

  set logOutput(LogOutput logOutput) {
    _logOutput = logOutput;
  }

  set logger(Logger logger) {
    _logger = logger;
  }

  set loggerBox(Logger logger) {
    _loggerBox = logger;
  }

  set loggerStack(Logger logger) {
    _loggerStack = logger;
  }

  Logger get logger {
    return _logger ??= Logger(
      filter: _logFilter ?? CustomFilter(),
      printer: CustomPrinter(methodCount: 0, noBoxingByDefault: true),
      output: _logOutput ?? CustomOutput(),
    );
  }

  Logger get loggerBox {
    return _loggerBox ??= Logger(
      filter: _logFilter ?? CustomFilter(),
      printer: CustomPrinter(methodCount: 0),
      output: _logOutput ?? CustomOutput(),
    );
  }

  Logger get loggerStack {
    return _loggerStack ??= Logger(
      filter: _logFilter ?? CustomFilter(),
      printer: CustomPrinter(methodCount: 20),
      output: _logOutput ?? CustomOutput(),
    );
  }
}

logV(dynamic message) => LogWrapper().logger.t(message);

logD(dynamic message) => LogWrapper().logger.d(message);

logI(dynamic message) => LogWrapper().logger.i(message);

logW(dynamic message) => LogWrapper().logger.w(message);

logE(dynamic message) => LogWrapper().logger.e(message);

logN(dynamic message) => LogWrapper().logger.f(message);

logBoxV(dynamic message) => LogWrapper().loggerBox.t(message);

logBoxD(dynamic message) => LogWrapper().loggerBox.d(message);

logBoxI(dynamic message) => LogWrapper().loggerBox.i(message);

logBoxW(dynamic message) => LogWrapper().loggerBox.w(message);

logBoxE(dynamic message) => LogWrapper().loggerBox.e(message);

logBoxN(dynamic message) => LogWrapper().loggerBox.f(message);

logStackV(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  LogWrapper().loggerStack.t(message, error: error, stackTrace: stackTrace);
}

logStackD(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  LogWrapper().loggerStack.d(message, error: error, stackTrace: stackTrace);
}

logStackI(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  LogWrapper().loggerStack.i(message, error: error, stackTrace: stackTrace);
}

logStackW(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  LogWrapper().loggerStack.w(message, error: error, stackTrace: stackTrace);
}

logStackE(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  LogWrapper().loggerStack.e(message, error: error, stackTrace: stackTrace);
}
