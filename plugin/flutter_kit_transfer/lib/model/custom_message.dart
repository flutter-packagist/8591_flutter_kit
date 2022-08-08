import 'package:flutter_kit_transfer/model/safe_convert.dart';

import 'base_message.dart';

enum MsgType { join, notify, text, file }

class JoinMessage extends BaseMessage {
  List<String> address = [];
  int messagePort = 0;
  int filePort = 0;

  JoinMessage({
    required this.address,
    required this.messagePort,
    required this.filePort,
  }) : super(msgType: MsgType.join.index);

  JoinMessage.fromJson(Map<String, dynamic>? json) : super.fromJson(json) {
    address = asList(json, 'address').map((e) => safeString(e)).toList();
    messagePort = asInt(json, 'message_port');
    filePort = asInt(json, 'file_port');
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['address'] = address;
    data['message_port'] = messagePort;
    data['file_port'] = filePort;
    return data;
  }
}

class NotifyMessage extends BaseMessage {
  String hash = '';
  List<String> address = [];
  int port = 0;

  NotifyMessage({
    required this.hash,
    required this.address,
    required this.port,
  }) : super(msgType: MsgType.notify.index);

  NotifyMessage.fromJson(Map<String, dynamic>? json) : super.fromJson(json) {
    hash = asString(json, 'hash');
    address = asList(json, 'address').map((e) => safeString(e)).toList();
    port = asInt(json, 'port');
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['hash'] = hash;
    data['address'] = address;
    data['port'] = port;
    return data;
  }
}

class TextMessage extends BaseMessage {
  String content = '';

  TextMessage({
    required this.content,
    required String fromDevice,
  }) : super(msgType: MsgType.text.index, deviceName: fromDevice);

  TextMessage.fromJson(Map<String, dynamic>? json) : super.fromJson(json) {
    content = asString(json, 'content');
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['content'] = content;
    return data;
  }
}

class FileMessage extends BaseMessage {
  String fileName = '';
  String filePath = '';
  String fileSize = '';
  List<String> address = [];
  String url = "";
  int port = -1;

  FileMessage({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.address,
    required this.port,
    required String fromDevice,
  }) : super(msgType: MsgType.file.index, deviceName: fromDevice);

  FileMessage.fromJson(Map<String, dynamic>? json) : super.fromJson(json) {
    fileName = asString(json, 'fileName');
    filePath = asString(json, 'filePath');
    fileSize = asString(json, 'fileSize');
    address = asList(json, 'address').map((e) => safeString(e)).toList();
    port = asInt(json, 'port');
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['fileName'] = fileName;
    data['filePath'] = filePath;
    data['fileSize'] = fileSize;
    data['address'] = address;
    data['port'] = port;
    return data;
  }
}
