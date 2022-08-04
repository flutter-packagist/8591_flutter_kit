import 'dart:convert';

import 'safe_convert.dart';

class BaseMessage {
  String deviceId = ""; // 设备id
  String deviceName = ""; // 设备名
  int msgType = -1; // 消息类型
  int platform = -1; // 当前设备所属平台
  String data = ""; // 数据

  BaseMessage({
    this.deviceId = "",
    this.deviceName = "",
    this.msgType = -1,
    this.platform = -1,
    this.data = "",
  });

  BaseMessage.fromJson(Map<String, dynamic>? json) {
    deviceId = asString(json, 'deviceId');
    deviceName = asString(json, 'deviceName');
    msgType = asInt(json, 'msgType');
    platform = asInt(json, 'platform');
    data = asString(json, 'data');
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'msgType': msgType,
        'platform': platform,
        'data': data,
      };

  @override
  String toString() => json.encode(this);
}
