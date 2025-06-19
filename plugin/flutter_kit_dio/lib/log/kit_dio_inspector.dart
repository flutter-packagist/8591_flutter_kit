///@title KitDioInspector
///@description
///@updateTime 2024/5/15 14:33
///@author 11022

import 'package:dio/dio.dart' show Dio;
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit_dio/widgets/icon.dart' as icon;

import 'kit_http_interceptor.dart';
import 'kit_pluggable_state.dart';

class KitDioInspector extends StatefulWidget implements Pluggable {
  KitDioInspector({
    Key? key,
    required this.dio,
    required bool outputConsole,
  }) : super(key: key) {
    dio.interceptors
        .add(KitDioLogInterceptor()..logOutput.outputConsole = outputConsole);
  }

  final Dio dio;

  @override
  KitDioPluggableState createState() => KitDioPluggableState();

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
