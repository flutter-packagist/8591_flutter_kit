import 'dart:convert';

import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:flutter_kit_transfer/platform/runtime_environment.dart';
import 'package:flutter_kit_transfer/service/chat_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  test("Chat Server", () {
    RuntimeEnv.init(packageName: "");
    ChatServer.start(receiveMessage: (request, headers) async {
      Map<String, dynamic> data = jsonDecode(await request.readAsString());
      logD("接受消息：$data");
      return Response.ok("success", headers: headers);
    });
  });
}
