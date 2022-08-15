import 'package:logger/logger.dart';

import 'custom_filter.dart';
import 'custom_output.dart';
import 'custom_printer.dart';

var logFilter = CustomFilter();
var logOutput = CustomOutput();

var logger = Logger(
  filter: logFilter,
  printer: CustomPrinter(methodCount: 0, noBoxingByDefault: true),
  output: logOutput,
);

var loggerBox = Logger(
  filter: logFilter,
  printer: CustomPrinter(methodCount: 0),
  output: logOutput,
);

var loggerStack = Logger(
  filter: logFilter,
  printer: CustomPrinter(methodCount: 5),
  output: logOutput,
);

logV(dynamic message) => logger.v(message);

logD(dynamic message) => logger.d(message);

logI(dynamic message) => logger.i(message);

logW(dynamic message) => logger.w(message);

logE(dynamic message) => logger.e(message);

logN(dynamic message) => logger.wtf(message);

logBoxV(dynamic message) => loggerBox.v(message);

logBoxD(dynamic message) => loggerBox.d(message);

logBoxI(dynamic message) => loggerBox.i(message);

logBoxW(dynamic message) => loggerBox.w(message);

logBoxE(dynamic message) => loggerBox.e(message);

logBoxN(dynamic message) => loggerBox.wtf(message);

logStackV(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  loggerStack.v(message, error, stackTrace);
}

logStackD(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  loggerStack.d(message, error, stackTrace);
}

logStackI(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  loggerStack.i(message, error, stackTrace);
}

logStackW(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  loggerStack.w(message, error, stackTrace);
}

logStackE(dynamic message, [dynamic error, StackTrace? stackTrace]) {
  loggerStack.e(message, error, stackTrace);
}
