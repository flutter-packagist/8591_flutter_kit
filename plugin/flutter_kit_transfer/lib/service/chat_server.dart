import 'dart:io';

import 'package:dio/dio.dart' hide Response;
import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:flutter_kit_transfer/platform/platform.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import '../config/config.dart';
import '../model/custom_message.dart';
import '../platform/runtime_environment.dart';
import '../utils/dio_util.dart';
import '../utils/socket_util.dart';
import 'init_server.dart';

class ChatServer {
  ChatServer._();

  static final ChatServer _instance = ChatServer._();

  factory ChatServer() => _instance;

  final Router app = Router();

  // 跨域资源共享
  final corsHeader = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Credentials': 'true',
  };

  // 发送加入消息的设备链接
  final List<String> _urlHasSendJoin = [];

  // 启动消息服务端
  Future<int> start({
    required Function(Request, Map<String, Object>) receiveMessage,
    required Function(Request, Map<String, Object>) readMessage,
  }) async {
    app.post('/message', (Request request) {
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return receiveMessage(request, corsHeader);
    });
    app.get('/message', (Request request) {
      return readMessage(request, corsHeader);
    });
    // 绑定index文件到根目录
    var handler = createStaticHandler(
      RuntimeEnv.filesPath ?? '',
      listDirectories: true,
      defaultDocument: 'index.html',
    );
    app.mount('/', handler);
    int port = await getSafePort(
      Config.chatPortRangeStart,
      Config.chatPortRangeEnd,
    );
    await io.serve(app, InternetAddress.anyIPv4, port, shared: true);
    logD('当前可使用的端口号：$port');
    return port;
  }

  Future<void> sendJoinEvent(
    String url,
    List<String> address,
    int shelfBindPort,
    int chatBindPort,
  ) async {
    if (_urlHasSendJoin.contains(url)) return;

    _urlHasSendJoin.add(url);
    logD('send join event: $url');
    JoinMessage message = JoinMessage(
      address: address,
      messagePort: chatBindPort,
      filePort: shelfBindPort,
    );
    message.deviceId = InitServer().deviceId;
    message.deviceName = InitServer().deviceName;
    message.platform = GetPlatform.type.index;
    try {
      await httpInstance.post("$url/message", data: message.toJson());
    } on DioError catch (e) {
      logStackE('发送加入消息失败', e, StackTrace.current);
    }
  }
}
