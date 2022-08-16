import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';

import '../utils/toast_util.dart';
import 'bubble_dialog.dart';

class JoinChatDialog extends StatefulWidget {
  final SendJoinEvent sendJoinEvent;

  const JoinChatDialog({
    Key? key,
    required this.sendJoinEvent,
  }) : super(key: key);

  @override
  State<JoinChatDialog> createState() => _JoinChatDialogState();
}

class _JoinChatDialogState extends State<JoinChatDialog> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 180.w,
          width: 300.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SizedBox(height: 10.w),
              Text(
                '加入房间',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.w,
                ),
              ),
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: textEditingController,
                  onSubmitted: (_) {},
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.w,
                      horizontal: 12.w,
                    ),
                    hintText: '请输入房间链接地址',
                    helperText: '链接地址在被连接设备的二维码处查看',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.w,
                    textBaseline: TextBaseline.ideographic,
                  ),
                ),
              ),
              SizedBox(height: 8.w),
              Container(
                margin: EdgeInsets.only(right: 20.w),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: joinChat,
                  child: Text(
                    '加入',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 16.w,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void joinChat() {
    if (textEditingController.text.isEmpty) {
      showToast('URL不能为空');
      return;
    }
    widget.sendJoinEvent(textEditingController.text);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
