import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:log_wrapper/log/custom_output.dart';
import 'package:log_wrapper/log_wrapper.dart';
import 'package:logger/logger.dart';

class LocalLogOutput extends CustomOutput {
  int _currentId = 0;

  @override
  void output(OutputEvent event) async {
    super.output(event);
    // 输出log到手机测试控制台
    var linesText = event.lines.join('\n');
    var logEvent = LogData(
      _currentId++,
      event.level,
      linesText,
      linesText.toLowerCase(),
    );
    ConsoleManager.addLog(logEvent);
  }
}
