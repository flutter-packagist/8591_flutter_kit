import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

const int _port = 4545;
// 组播地址
final InternetAddress _mDnsAddressIPv4 = InternetAddress('224.0.0.251');

typedef MessageReceivedListener = void Function(String data, String address);

/// 通过组播+广播的方式，让设备在局域网能够相互被发现
class Multicast {
  final int port;

  Multicast({this.port = _port});

  final ReceivePort _receivePort = ReceivePort();
  final List<MessageReceivedListener> _receivedListeners = [];
  Isolate? isolate;
  bool _isBroadcasting = false;
  bool _isReceiving = false;

  Future<void> startBroadcast(
    List<String> messages, {
    Duration duration = const Duration(seconds: 1),
  }) async {
    if (_isBroadcasting) return;
    _isBroadcasting = true;
    isolate = await Isolate.spawn(
      _multicastIsolate,
      IsolateArgs(
        _receivePort.sendPort,
        port,
        messages,
        duration,
      ),
    );
  }

  void stopBroadcast() {
    if (!_isBroadcasting) return;
    _isBroadcasting = false;
    isolate?.kill();
  }

  void addListener(MessageReceivedListener listener) {
    if (!_isReceiving) {
      _receiveBroadcast();
      _isReceiving = true;
    }
    _receivedListeners.add(listener);
  }

  void removeListener(MessageReceivedListener listener) {
    if (_receivedListeners.contains(listener)) {
      _receivedListeners.remove(listener);
    }
  }

  /// 接收udp广播消息
  Future<void> _receiveBroadcast() async {
    RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reuseAddress: true,
      ttl: 255,
    ).then((RawDatagramSocket socket) {
      // 接收组播消息
      socket.joinMulticast(_mDnsAddressIPv4);
      // 开启广播支持
      socket.broadcastEnabled = true;
      socket.readEventsEnabled = true;
      socket.listen((RawSocketEvent rawSocketEvent) async {
        final Datagram? datagram = socket.receive();
        if (datagram == null) return;

        // 解析接收消息
        String message = utf8.decode(datagram.data);
        for (MessageReceivedListener messageReceived in _receivedListeners) {
          messageReceived.call(message, datagram.address.address);
        }
      });
    });
  }
}

void _multicastIsolate(IsolateArgs args) {
  _sendBroadcast(
    args.sendPort,
    args.port,
    args.messages,
    args.duration,
  );
}

Future<void> _sendBroadcast(
  SendPort sendPort,
  int port,
  List<String> messages,
  Duration duration,
) async {
  RawDatagramSocket socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4, 0,
      ttl: 255, reuseAddress: true);
  socket.broadcastEnabled = true;
  socket.readEventsEnabled = true;
  Timer.periodic(duration, (timer) async {
    for (String data in messages) {
      socket.broadcast(data, port);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  });
}

class IsolateArgs {
  IsolateArgs(
    this.sendPort,
    this.port,
    this.messages,
    this.duration,
  );

  final SendPort sendPort;
  final int port;
  final List<String> messages;
  final Duration duration;
}

extension IpString on String {
  bool get isIPv4 => RegExp(r'^(?:(?:^|\.)(?:2(?:5[0-5]|[0-4]\d)|1?\d?\d)){4}$')
      .hasMatch(this);
}

extension Broadcast on RawDatagramSocket {
  Future<void> broadcast(String msg, int port) async {
    List<int> dataList = utf8.encode(msg);
    send(dataList, _mDnsAddressIPv4, port);
    await Future.delayed(const Duration(milliseconds: 10));
    final List<String> addressList = await localAddress();
    // 遍历IP并改成广播地址
    for (String addressStr in addressList) {
      var addressItem = addressStr.split('.');
      addressItem.removeLast();
      String addressPrefix = addressItem.join('.');
      InternetAddress address = InternetAddress('$addressPrefix.255');
      send(dataList, address, port);
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
}
