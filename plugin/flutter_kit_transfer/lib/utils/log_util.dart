import 'package:log_wrapper/log/log.dart' as log;

void logV(msg) {
  log.logV(msg + logTag());
}

void logD(msg) {
  log.logD(msg + logTag());
}

void logI(msg) {
  log.logI(msg + logTag());
}

void logW(msg) {
  log.logW(msg + logTag());
}

void logE(msg) {
  log.logE(msg + logTag());
}

String logTag() {
  List<String> stackList = StackTrace.current.toString().split("\n");
  if (stackList.length < 2) return "";
  String line = stackList[2];
  List<String> lineList = line.split("package:");
  if (lineList.length < 2) return "";
  String packageLine = lineList[1];
  packageLine = packageLine.replaceAll(")", "]");
  return " [$packageLine";
}
