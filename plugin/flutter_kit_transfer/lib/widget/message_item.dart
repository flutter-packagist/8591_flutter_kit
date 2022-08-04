import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_transfer/model/custom_message.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';

import '../utils/toast_util.dart';

class TextMessageItem extends StatelessWidget {
  final TextMessage message;
  final bool sendByUser;

  const TextMessageItem({
    Key? key,
    required this.message,
    required this.sendByUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          sendByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          ),
          constraints: BoxConstraints(maxWidth: 200.w),
          child: SelectableText(
            message.content,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.w,
              letterSpacing: 1,
            ),
          ),
        ),
        if (!sendByUser)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                showToast('内容已复制');
                await Clipboard.setData(ClipboardData(text: message.content));
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.content_copy,
                  size: 18.w,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
