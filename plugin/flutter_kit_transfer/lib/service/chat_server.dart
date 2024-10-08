import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' hide Response;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import '../compatible/platform/platform.dart';
import '../compatible/runtime_environment.dart';
import '../config/config.dart';
import '../model/custom_message.dart';
import '../utils/dio_util.dart';
import '../utils/file_util.dart';
import '../utils/log_util.dart';
import '../utils/socket_util.dart';
import 'init_server.dart';

class ChatServer {
  ChatServer._();

  static final ChatServer _instance = ChatServer._();

  factory ChatServer() => _instance;

  late Router app;

  late HttpServer server;

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
    app = Router();
    app.post('/message', (Request request) {
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return receiveMessage(request, corsHeader);
    });
    app.get('/message', (Request request) {
      return readMessage(request, corsHeader);
    });
    app.get('/upload', (Request request) {
      return Response.ok("upload access", headers: corsHeader);
    });
    app.post('/upload', (Request request) async {
      // 获取上传的数据流
      logW("request: ${request.headers}");
      String contentType = request.headers['content-type'] ?? '';
      HeaderValue header = HeaderValue.parse(contentType);
      String boundary = header.parameters['boundary'] ?? '';
      final transformer = MimeMultipartTransformer(boundary);
      final parts = await transformer.bind(request.read()).toList();
      // 创建文件存储目录
      final dir = "${(await getTemporaryDirectory()).path}${separator}upload";
      Directory(dir).createSync(recursive: true);
      // 读取上传数据参数
      String fileName = DateTime.now().toIso8601String();
      String filePath = "";
      for (MimeMultipart part in parts) {
        final contentDisposition = part.headers['content-disposition'] ?? '';
        final content = await part.toList();
        if (contentDisposition.contains('"filename"')) {
          fileName = utf8.decode(content[0]);
        } else if (contentDisposition.contains('"file"')) {
          filePath = FileUtil.getSafePath('$dir$separator$fileName');
          List<int> bytes = [];
          for (var byte in content) {
            bytes.addAll(byte);
          }
          await File(filePath).writeAsBytes(bytes);
        }
      }
      return Response.ok(filePath, headers: corsHeader);
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
    server = await io.serve(app, InternetAddress.anyIPv4, port, shared: true);
    logD('当前可使用的端口号：$port');
    return port;
  }

  Future<void> stop() async {
    await server.close(force: true);
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
      await httpInstance.post("${url}/message", data: message.toJson());
    } on DioException catch (e) {
      logE('发送加入消息失败：${e.message}');
    }
  }
}
