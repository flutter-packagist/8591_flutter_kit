import 'package:dio/dio.dart';

import '../constants/extensions.dart';
import '../core/instances.dart';

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
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Create an empty response with the [RequestOptions] for delivery.
    err.response ??= Response<dynamic>(requestOptions: err.requestOptions);
    err.response!.requestOptions.extra[dioExtraEndTime] = _timestamp;
    err.response!.requestOptions.extra[dioExtraExpand] = false;
    InspectorInstance.httpContainer.addRequest(err.response!);
    handler.next(err);
  }
}
