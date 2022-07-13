import 'package:logger/logger.dart';

/// Prints all logs with `level >= Logger.level` even in production.
class CustomFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level!.index;
  }
}
