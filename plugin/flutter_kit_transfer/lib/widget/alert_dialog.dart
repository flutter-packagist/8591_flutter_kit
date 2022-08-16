import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';

/// 统一样式弹框
class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final String? btnCancel;
  final Color? textColorCancel;
  final String? btnConfirm;
  final Color? textColorConfirm;
  final bool singleBtn;
  final VoidCallback? onBtnCancelTap;
  final VoidCallback? onBtnConfirmTap;

  const CustomAlertDialog({
    Key? key,
    this.title,
    this.content,
    this.btnConfirm,
    this.textColorConfirm,
    this.btnCancel,
    this.textColorCancel,
    this.singleBtn = false,
    this.onBtnCancelTap,
    this.onBtnConfirmTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text(title!, textAlign: TextAlign.center) : null,
      titleTextStyle: TextStyle(fontSize: 18.w, color: Colors.black),
      content:
          content != null ? Text(content!, textAlign: TextAlign.center) : null,
      actions: singleBtn ? singleBtnAction : twoBtnAction,
      buttonPadding: EdgeInsets.zero,
    );
  }

  List<Widget> get singleBtnAction {
    return [
      Divider(height: 2.w, thickness: 2.w, color: Colors.grey.shade400),
      TextButton(
        onPressed: onBtnConfirmTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Text(
          btnConfirm ?? "是",
          style: TextStyle(
            fontSize: 14.w,
            color: textColorConfirm ?? Colors.blue,
          ),
        ),
      ),
    ];
  }

  List<Widget> get twoBtnAction {
    return [
      Divider(height: 1.w, thickness: 1.w, color: Colors.grey),
      SizedBox(
        width: double.infinity,
        height: 45.w,
        child: Row(children: [
          Expanded(
            child: TextButton(
              onPressed: onBtnConfirmTap,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Text(
                btnCancel ?? "否",
                style: TextStyle(
                  fontSize: 14.w,
                  color: textColorConfirm ?? Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Container(height: 45.w, width: 1.w, color: Colors.grey),
          Expanded(
            child: TextButton(
              onPressed: onBtnConfirmTap,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Text(
                btnConfirm ?? "是",
                style: TextStyle(
                  fontSize: 14.w,
                  color: textColorConfirm ?? Colors.blue,
                ),
              ),
            ),
          ),
        ]),
      ),
    ];
  }
}
