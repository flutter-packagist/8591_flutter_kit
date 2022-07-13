import 'package:flutter_kit_log/log/log.dart';

void main() {
  DateTime dateTime = DateTime.now();
  String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  logD(date);
}