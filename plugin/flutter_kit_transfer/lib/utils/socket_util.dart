import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:log_wrapper/log/log.dart';

import 'dio_util.dart';

/// 寻找未被占用的端口
Future<int> getSafePort(int rangeStart, int rangeEnd) async {
  if (rangeStart == rangeEnd) {
    // 说明都失败了
    return -1;
  }
  try {
    await ServerSocket.bind(
      '0.0.0.0',
      rangeStart,
      shared: true,
    );
    return rangeStart;
  } catch (e) {
    return await getSafePort(rangeStart + 1, rangeEnd);
  }
}

/// 遍历获取本地网卡IP
Future<List<String>> localAddress() async {
  final List<String> addressList = [];
  final List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: false, type: InternetAddressType.IPv4);
  // 遍历网卡及网卡IP
  for (final NetworkInterface netInterface in interfaces) {
    for (final InternetAddress netAddress in netInterface.addresses) {
      if (netAddress.address.isIPv4) {
        addressList.add(netAddress.address);
      }
    }
  }
  return addressList;
}

/// 发起http get请求，用来校验网络是否互通；如果不通，会返回null
Future<String?> checkToken(String url) async {
  logI('访问 $url/check_token 以检测网络是否互通');
  Completer lock = Completer();
  CancelToken cancelToken = CancelToken();
  Response response;
  Future.delayed(const Duration(milliseconds: 1000), () {
    if (!lock.isCompleted) {
      cancelToken.cancel();
    }
  });
  try {
    response = await httpInstance.get(
      '$url/check_token',
      cancelToken: cancelToken,
    );
    if (!lock.isCompleted) {
      lock.complete(response.data);
    }
    logI('$url/check_token 响应 ${response.data}');
  } catch (e) {
    if (!lock.isCompleted) {
      lock.complete(null);
    }
  }
  return await lock.future;
}

/// 获取能够连接的链接地址
Future<String> getUrlByAddressAndPort(
  List<String> addressList,
  int port,
) async {
  for (String address in addressList) {
    String? token = await checkToken('http://$address:$port');
    if (token != null) {
      return 'http://$address';
    }
  }
  return "";
}

extension IpString on String {
  bool get isIPv4 => RegExp(
          r'((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}')
      .hasMatch(this);
}
