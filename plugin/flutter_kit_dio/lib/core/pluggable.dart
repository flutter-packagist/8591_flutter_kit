import 'package:dio/dio.dart' show Dio;
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';

import '../ext/log_interceptor.dart';
import '../widgets/icon.dart' as icon;
import '../widgets/pluggable_state.dart';

class DioInspector extends StatefulWidget implements Pluggable {
  DioInspector({Key? key, required this.dio}) : super(key: key) {
    dio.interceptors.add(DioLogInterceptor());
  }

  final Dio dio;

  @override
  DioPluggableState createState() => DioPluggableState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'DioInspector';

  @override
  String get displayName => '网络请求';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  bool get keepState => true;
}
