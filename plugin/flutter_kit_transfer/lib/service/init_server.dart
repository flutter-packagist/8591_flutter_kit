import 'dart:async';

import 'package:log_wrapper/log/log.dart';
import 'package:path_provider/path_provider.dart';

import '../compatible/platform/platform.dart';
import '../compatible/runtime_environment.dart';
import '../utils/file_util.dart';
import '../utils/socket_util.dart';
import '../utils/unique_util.dart';
import 'multicast.dart';

class InitServer {
  InitServer._();

  static final InitServer _instance = InitServer._();

  factory InitServer() => _instance;

  Multicast multicast = Multicast();
  List<String> broadcastMessage = [];

  /// 初始化锁：
  /// 1.发送join消息需要等deviceId初始化完成
  /// 2.发送文件需要等套接字初始化
  Completer initLock = Completer();

  /// 当前设备唯一id
  String deviceId = '';

  /// 当前设备名
  String deviceName = '';

  /// 是否已经初始化
  bool hasInit = false;

  Future<void> init({
    required String packageName,
    String? appSupportDirectory,
  }) async {
    if (GetPlatform.isWeb) {
      deviceId = await UniqueUtil.getDeviceId();
      deviceName = await UniqueUtil.getDeviceName();
      return;
    }
    final appSupportPath = (await getApplicationSupportDirectory()).path;
    RuntimeEnv.init(
      packageName: packageName,
      appSupportDirectory: appSupportDirectory ?? appSupportPath,
    );
    deviceId = await UniqueUtil.getDeviceId();
    deviceName = await UniqueUtil.getDeviceName();
  }

  Future<void> initLazy() async {
    if (GetPlatform.isWeb) return;
    if (hasInit) return;
    hasInit = true;
    multicast.addListener(_receiveUdpMessage);
    FileUtil.unpackWebResource();
  }

  /// 接收广播消息
  Future<void> _receiveUdpMessage(String message, String address) async {
    final String deviceId = message.split(',').first;
    final String port = message.split(',').last;

    final List<String> addressList = await localAddress();
    if (addressList.contains(address)) return;

    if (deviceId.startsWith('clipboard')) {
      logD("clipboard");
    } else if (deviceId.trim() != await UniqueUtil.getDeviceId()) {
      logD("join message: http://$address:$port");
    }
  }

  Future<void> startSendBroadcast(String data) async {
    if (!broadcastMessage.contains(data)) {
      broadcastMessage.add(data);
    }
    multicast.startBroadcast(broadcastMessage);
  }

  Future<void> stopSendBroadcast() async {
    multicast.stopBroadcast();
  }
}
