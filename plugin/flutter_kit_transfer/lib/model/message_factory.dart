import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/model/base_message.dart';
import 'package:flutter_kit_transfer/model/custom_message.dart';
import 'package:flutter_kit_transfer/model/safe_convert.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';

import '../platform/platform.dart';
import '../service/device_manager.dart';
import '../widget/message_item.dart';

class MessageFactory {
  static BaseMessage fromJson(Map<String, dynamic> json) {
    MsgType msgType = MsgType.values[asInt(json, 'msgType')];
    switch (msgType) {
      case MsgType.join:
        return JoinMessage.fromJson(json);
      case MsgType.notify:
        return NotifyMessage.fromJson(json);
      case MsgType.text:
        return TextMessage.fromJson(json);
      case MsgType.file:
        return FileMessage.fromJson(json);
    }
  }

  static Widget? getMessageItem(BaseMessage message, bool sendBySelf) {
    Widget? child;

    if (message is TextMessage) {
      child = TextMessageItem(message: message, sendBySelf: sendBySelf);
    } else if (message is FileMessage) {
      child = FileMessageItem(message: message, sendBySelf: sendBySelf);
    }

    if (child != null) {
      Color deviceColor =
          Device.getColor(DevicePlatform.values[message.platform]);
      return Align(
        alignment: sendBySelf ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 8.w,
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment:
                  sendBySelf ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: deviceColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    message.deviceName,
                    style: TextStyle(
                      fontSize: 12.w,
                      color: deviceColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.w),
            child,
          ]),
        ),
      );
    }

    return child;
  }
}
