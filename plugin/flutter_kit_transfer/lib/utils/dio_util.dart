import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_kit_dio/core/instances.dart';
import 'package:flutter_kit_dio/ext/log_interceptor.dart';
import 'package:log_wrapper/log/log.dart';

const String dioExtraEndTime = 'dio_end_time';
const String dioExtraExpand = 'dio_expand';

Dio httpInstance = DioUtil.getInstance();

class DioUtil {
  DioUtil._();

  static Dio? _instance;

  static Dio getInstance() {
    if (_instance == null) {
      _instance = Dio();
      _instance!.interceptors.add(DioLogInterceptor());
    }
    return _instance!;
  }
}

const JsonDecoder _decoder = JsonDecoder();
const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

int get _timestamp => DateTime.now().millisecondsSinceEpoch;

class MyDioLogInterceptor extends DioLogInterceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions request = response.requestOptions;
    if (request.uri.toString().endsWith("/message") &&
        request.method == "GET") {
      if (response.data != null) {
        String responseData = "";
        try {
          dynamic dataMap = _decoder.convert(response.data);
          responseData = _encoder.convert(dataMap);
        } on FormatException catch (_) {
          responseData = response.data.toString();
        }
        logN(responseData);
      }
      response.requestOptions.extra[dioExtraEndTime] = _timestamp;
      response.requestOptions.extra[dioExtraExpand] = false;
      InspectorInstance.httpContainer.addRequest(response);
      handler.next(response);
      return;
    }
    super.onResponse(response, handler);
  }
}
