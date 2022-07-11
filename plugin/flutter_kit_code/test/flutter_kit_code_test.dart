import 'package:flutter_test/flutter_test.dart';

void main() {
  String url = "libraries/@100029200/scripts/dart:convert/codec.dart/0";
  int index = url.indexOf("scripts/");
  int lastIndex = url.lastIndexOf("/");
  String subStr = url.substring(index + 8, lastIndex);
  print(index);
  print(lastIndex);
  print(subStr);
}
