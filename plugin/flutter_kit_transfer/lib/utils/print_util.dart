import 'dart:convert';

JsonDecoder decoder = const JsonDecoder();
JsonEncoder encoder = const JsonEncoder.withIndent('  ');

String prettyJsonString(String data) {
  dynamic dataMap = decoder.convert(data);
  return encoder.convert(dataMap);
}

String prettyJsonMap(Map<String, dynamic> data) {
  return encoder.convert(data);
}
