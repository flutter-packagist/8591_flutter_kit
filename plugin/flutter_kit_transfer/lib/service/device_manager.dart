import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/dio_util.dart';
import 'package:log_wrapper/log/log.dart';

import '../platform/platform.dart';

class DeviceManager {
  DeviceManager._();

  static final DeviceManager _instance = DeviceManager._();

  factory DeviceManager() => _instance;

  final List<Device> _connectedDevice = [];

  List<Device> get connectedDevice => _connectedDevice;

  void onConnect({
    required String id,
    required String name,
    required DevicePlatform platform,
    required String uri,
    required int port,
  }) {
    List<String> idList = _connectedDevice.map((e) => e.id).toList();
    if (!idList.contains(id)) {
      _connectedDevice.add(Device(
        id: id,
        name: name,
        platform: platform,
        uri: uri,
        port: port,
      ));
    }
    logW("connectedDevice: ${_connectedDevice.toList()}");
  }

  void onClose(String id) {
    _connectedDevice.removeWhere((element) => element.id == id);
  }

  void sendData(Map<String, dynamic> data) {
    if (GetPlatform.isWeb) {
      httpInstance.post("message", data: data);
      return;
    }
    Set<String> urls = {};
    urls.addAll(_connectedDevice
        .where((e) => e.uri.isNotEmpty)
        .map((e) => "${e.uri}:${e.port}/"));
    for (String url in urls) {
      httpInstance.post("${url}message", data: data);
    }
  }
}

class Device {
  final String id;
  final String name;
  final DevicePlatform platform;
  final String uri;
  final int port;

  Device({
    required this.id,
    required this.name,
    required this.platform,
    required this.uri,
    required this.port,
  });

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Device) {
      return id == other.id;
    }
    return false;
  }

  Color get deviceColor => getColor(platform);

  static Color getColor(DevicePlatform platform) {
    switch (platform) {
      case DevicePlatform.web:
        return const Color(0xffED796A);
      case DevicePlatform.mobile:
        return const Color(0xff6A6DED);
      case DevicePlatform.desktop:
        return const Color(0xff317DEE);
      default:
        return Colors.indigo;
    }
  }

  @override
  String toString() {
    return 'id:$id name:$name platform:$platform address:$uri $port';
  }
}
