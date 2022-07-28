import 'dart:io';

import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import '../config/config.dart';
import '../platform/runtime_environment.dart';
import '../utils/socket_util.dart';

class ChatServer {
  static final Router app = Router();

  // 跨域资源共享
  static final corsHeader = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Credentials': 'true',
  };

  // 启动消息服务端
  static Future<int> start({
    required Function(Request, Map<String, Object>?) receiveMessage,
  }) async {
    app.post('/', (Request request) async {
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return receiveMessage(request, corsHeader);
    });
    // 绑定index文件到根目录
    var handler = createStaticHandler(
      RuntimeEnv.filesPath ?? "",
      listDirectories: true,
      defaultDocument: 'index.html',
    );
    app.mount('/', handler);
    int port = await getSafePort(
      Config.chatPortRangeStart,
      Config.chatPortRangeEnd,
    );
    logD("当前可使用的端口号：$port");
    // ignore: unused_local_variable
    HttpServer server = await io.serve(
      app,
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    return port;
  }
}
