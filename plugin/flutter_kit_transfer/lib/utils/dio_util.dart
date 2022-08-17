import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_kit_dio/constants/extensions.dart';
import 'package:flutter_kit_dio/core/instances.dart';
import 'package:flutter_kit_dio/models/http_interceptor.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';

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
