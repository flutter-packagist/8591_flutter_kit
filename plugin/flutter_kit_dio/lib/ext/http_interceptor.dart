import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';

import '../core/instances.dart';
import 'extensions.dart';

const JsonDecoder _decoder = JsonDecoder();
const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

int get _timestamp => DateTime.now().millisecondsSinceEpoch;

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
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    response.requestOptions.extra[dioExtraEndTime] = _timestamp;
    response.requestOptions.extra[dioExtraExpand] = false;
    InspectorInstance.httpContainer.addRequest(response);
    logBoxN(getPrintLog(response));
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Create an empty response with the [RequestOptions] for delivery.
    err.response ??= Response<dynamic>(requestOptions: err.requestOptions);
    err.response!.requestOptions.extra[dioExtraEndTime] = _timestamp;
    err.response!.requestOptions.extra[dioExtraExpand] = false;
    InspectorInstance.httpContainer.addRequest(err.response!);
    logBoxE(getPrintLog(err.response!));
    handler.next(err);
  }

  String getPrintLog(Response<dynamic> response) {
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
      try {
        if (request.data is FormData) {
          requestData = "${(request.data as FormData).fields.join(",")}"
              "\n${(request.data as FormData).files.join(",")}";
        } else {
          requestData = _encoder.convert(request.data);
        }
      } on Exception catch (_) {
        requestData = request.data.toString();
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
      } on FormatException catch (_) {
        responseData = response.data.toString();
      }
      sb.write("$responseData\n");
    }

    return sb.toString();
  }
}
