import 'package:log_wrapper/log/log.dart';

void main() {
  DateTime dateTime = DateTime.now();
  String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  logD(date);
}