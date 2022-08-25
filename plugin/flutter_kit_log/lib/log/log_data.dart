import 'package:logger/logger.dart';

class LogData {
  final int id;
  final Level level;
  final String text;
  final String lowerCaseText;

  LogData(this.id, this.level, this.text, this.lowerCaseText);
}
