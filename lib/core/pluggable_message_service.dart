import 'dart:async';

import 'package:flutter_kit/core/pluggable.dart';

import 'plugin_manager.dart';

class PluggableMessageService {
  static final PluggableMessageService _instance =
      PluggableMessageService._internal();

  factory PluggableMessageService() {
    return _instance;
  }

  // ignore: close_sinks
  StreamController<PluggableMessage> messageStreamController =
      StreamController.broadcast();

  Map<String, PluggableMessageInfo> get pluggableMessageData =>
      _pluggableMessageData;
  Map<String, PluggableMessageInfo> _pluggableMessageData = {};

  PluggableMessageService._internal() {
    _pluggableMessageData = {};
  }

  void resetListener() {
    clearListener();

    PluginManager().pluginsMap.values
        .whereType<PluggableWithStream>()
        .forEach((pluggable) {
      // ignore: cancel_subscriptions
      final subscription = pluggable.stream.where((event) {
        return pluggable.streamFilter(event);
      }).listen((event) {
        _pluggableMessageData[pluggable.name]!.increaseCounter();
        _sendSink(pluggable);
      });
      _pluggableMessageData.update(pluggable.name, (old) {
        old.subscription?.cancel();
        return PluggableMessageInfo.subscription(subscription);
      }, ifAbsent: () => PluggableMessageInfo.subscription(subscription));
    });
  }

  int countAll(List<Pluggable?> pluggable) {
    int result = 0;
    pluggable.map((e) => e!.name).toSet().forEach((element) {
      result += (_pluggableMessageData[element]?.count ?? 0);
    });
    return result;
  }

  int count(Pluggable pluggable) =>
      _pluggableMessageData[pluggable.name]?.count ?? 0;

  void resetCounter(Pluggable pluggable) {
    _pluggableMessageData[pluggable.name]?.resetCounter();
    _sendSink(pluggable);
  }

  void clearListener() {
    for (var messageInfo in _pluggableMessageData.values) {
      messageInfo.subscription?.cancel();
    }
    _pluggableMessageData.clear();
  }

  void _sendSink(Pluggable pluggable) {
    messageStreamController.sink.add(PluggableMessage.create(
        pluggable.name, PluggableMessageService().count(pluggable)));
  }
}

class PluggableMessageInfo {
  StreamSubscription<dynamic>? _subscription;
  int _count = 0;

  StreamSubscription<dynamic>? get subscription => _subscription;

  int get count => _count;

  PluggableMessageInfo.subscription(StreamSubscription<dynamic> subscription) {
    _subscription = subscription;
    _count = 0;
  }

  void increaseCounter() {
    _count++;
  }

  void resetCounter() {
    _count = 0;
  }
}

class PluggableMessage {
  final int _count;
  final String _key;

  int get count => _count;

  String get key => _key;

  PluggableMessage.create(this._key, this._count);
}
