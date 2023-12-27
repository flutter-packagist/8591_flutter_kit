import 'package:flutter/widgets.dart';

class ChatModel {
  /// 当前连接状态
  bool connectState = false;

  /// 本机的ip地址列表
  List<String> addressList = [];

  /// 消息服务器成功绑定的端口
  int messageBindPort = -1;

  /// 文件服务器成功绑定的端口
  int shelfBindPort = -1;
  int fileServerPort = -1;

  /// 列表渲染的widget列表
  List<Widget> chatWidgetList = [];

  /// 消息队列，发送的消息会存到这个队列中，连接服务的客户端从队列中轮询取消息
  List<Map<String, dynamic>> messageQueue = [];

  /// 消息缓存，缓存开启服务的设备与客户端的所有交互的消息
  List<Map<String, dynamic>> messageCache = [];

  /// 当前是否有拖拽动作
  bool dragging = false;

  /// 输入框相关状态
  bool inputMultiline = false;
}
