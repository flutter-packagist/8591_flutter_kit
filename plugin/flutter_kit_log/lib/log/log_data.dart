import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LogData {
  final int id;
  final Level level;
  final TextSpan span;
  final String lowerCaseText;

  LogData(this.id, this.level, this.span, this.lowerCaseText);
}
