import 'package:dio/dio.dart';

const String dioExtraStartTime = 'dio_start_time';
const String dioExtraEndTime = 'dio_end_time';
const String dioExtraExpand = 'dio_expand';

extension ResponseExtension on Response<dynamic> {
  bool get isExpand => requestOptions.extra[dioExtraExpand] as bool;

  set isExpand(bool value) => requestOptions.extra[dioExtraExpand] = value;

  int get startTimeMilliseconds =>
      requestOptions.extra[dioExtraStartTime] as int;

  int get endTimeMilliseconds => requestOptions.extra[dioExtraEndTime] as int;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimeMilliseconds);

  DateTime get endTime =>
      DateTime.fromMillisecondsSinceEpoch(endTimeMilliseconds);
}
