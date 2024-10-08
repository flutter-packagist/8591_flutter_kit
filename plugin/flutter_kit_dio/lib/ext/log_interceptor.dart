
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_kit_dio/core/instances.dart';
import 'package:log_wrapper/log/log.dart';

/// ==============================================================
/// 拦截器：日志打印
/// ==============================================================
const String dioExtraStartTime = 'dio_start_time';
const String dioExtraEndTime = 'dio_end_time';
const String dioExtraExpand = 'dio_expand';

extension ResponseExtension on Response<dynamic> {
  bool get isExpand =>
      requestOptions.extra[dioExtraExpand] is bool ? requestOptions
          .extra[dioExtraExpand] as bool : false;

  set isExpand(bool value) => requestOptions.extra[dioExtraExpand] = value;

  int get startTimeMilliseconds =>
      requestOptions.extra[dioExtraStartTime] is int ? requestOptions
          .extra[dioExtraStartTime] as int : 0;

  int get endTimeMilliseconds =>
      requestOptions.extra[dioExtraEndTime] is int ? requestOptions
          .extra[dioExtraEndTime] as int : 0;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startTimeMilliseconds);

  DateTime get endTime =>
      DateTime.fromMillisecondsSinceEpoch(endTimeMilliseconds);
}

const JsonDecoder _decoder = JsonDecoder();
const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

int get _timestamp =>
    DateTime
        .now()
        .millisecondsSinceEpoch;

/// Implement a [Interceptor] to handle dio methods.
///
/// Main idea about this interceptor:
///  - Use [RequestOptions.extra] to store our timestamps.
///  - Add [dioExtraStartTime] when a request was requested.
///  - Add [dioExtraEndTime] when a response is respond or thrown an error.
///  - Deliver the [Response] to the container.
class DioLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[dioExtraStartTime] = _timestamp;
    logBoxN(getRequestLog(options));
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response,
      ResponseInterceptorHandler handler,) {
    response.requestOptions.extra[dioExtraEndTime] = _timestamp;
    response.requestOptions.extra[dioExtraExpand] = false;
    InspectorInstance.httpContainer.addRequest(response);
    logBoxN(getResponseLog(response));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Create an empty response with the [RequestOptions] for delivery.
    var response = Response<dynamic>(requestOptions: err.requestOptions);
    response.requestOptions.extra[dioExtraEndTime] = _timestamp;
    response.requestOptions.extra[dioExtraExpand] = false;
    InspectorInstance.httpContainer.addRequest(response);
    logBoxE(getResponseLog(response));
    logBoxE(err);
    handler.next(err);
  }

  String getRequestLog(RequestOptions request) {
    RequestOptions options = request;
    StringBuffer sb = StringBuffer();
    sb.write("请求链接：${options.uri}\n");
    sb.write("请求方式：${options.method}\n");
    if (options.headers.isNotEmpty) {
      sb.write("请求头部：\n");
      options.headers.forEach((key, value) {
        if (value is List) {
          for (var e in value) {
            sb.writeln('$key: $e');
          }
        } else {
          sb.writeln('$key: $value');
        }
      });
    }
    if (request.data != null) {
      sb.write("请求参数：\n");
      String requestData = "";
      if (request.data is FormData) {
        FormData formData = request.data as FormData;
        requestData = formData.fields
            .map((e) => "${e.key}: ${e.value}")
            .toList()
            .join("\n");
      } else {
        try {
          requestData = _encoder.convert(request.data);
        } catch (_) {
          requestData = request.data.toString();
        }
      }
      sb.write("$requestData\n");
    }
    return sb.toString();
  }

  String getResponseLog(Response<dynamic> response) {
    RequestOptions request = response.requestOptions;
    StringBuffer sb = StringBuffer();
    sb.write("请求时间：${response.startTime}\n");
    sb.write("请求链接：${request.uri}\n");
    sb.write("请求方式：${request.method}\n");
    Duration duration = response.endTime.difference(response.startTime);
    sb.write("请求时长：${duration.inMilliseconds}ms\n");
    sb.write("状态码：${response.statusCode ?? 0}\n\n");
    if (request.headers.isNotEmpty) {
      sb.write("请求头部：\n");
      request.headers.forEach((key, value) {
        if (value is List) {
          for (var e in value) {
            sb.writeln('$key: $e');
          }
        } else {
          sb.writeln('$key: $value');
        }
      });
      sb.write("\n");
    }
    if (request.data != null) {
      sb.write("请求参数：\n");
      String requestData = "";
      if (request.data is FormData) {
        FormData formData = request.data as FormData;
        requestData = formData.fields
            .map((e) => "${e.key}: ${e.value}")
            .toList()
            .join("\n");
      } else {
        try {
          requestData = _encoder.convert(request.data);
        } catch (_) {
          requestData = request.data.toString();
        }
      }
      sb.write("$requestData\n");
    }
    if (!response.headers.isEmpty) {
      sb.write("响应头部：\n");
      response.headers.forEach((key, value) {
        for (var e in value) {
          sb.writeln('$key: $e');
        }
      });
      sb.write("\n");
    }
    if (response.data != null) {
      sb.write("响应内容：\n");
      String responseData = "";
      try {
        if (response.data is String) {
          dynamic dataMap = _decoder.convert(response.data);
          responseData = _encoder.convert(dataMap);
        } else {
          dynamic prettyString = _encoder.convert(response.data);
          responseData = prettyString;
        }
      } catch (_) {
        responseData = response.data.toString();
      }
      sb.write("$responseData\n");
    }

    return sb.toString();
  }
}
