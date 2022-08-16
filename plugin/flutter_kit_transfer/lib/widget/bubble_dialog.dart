import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/dialog_util.dart';
import 'alert_dialog.dart';
import 'join_chat_dialog.dart';
import 'qr_scan_view.dart';

typedef SendJoinEvent = void Function(String url);

class BubbleDialog extends StatefulWidget {
  final SendJoinEvent sendJoinEvent;

  const BubbleDialog({Key? key, required this.sendJoinEvent}) : super(key: key);

  @override
  State<BubbleDialog> createState() => _BubbleDialogState();
}

class _BubbleDialogState extends State<BubbleDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.w,
      width: 150.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.w),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            icon: Icons.qr_code_scanner,
            text: "扫描二维码",
            onTap: () async {
              bool cameraCanUse = await checkCamera();
              if (cameraCanUse) {
                enterQrScanPage();
              }
            },
          ),
          btn(
            icon: Icons.add_box_outlined,
            text: "加入房间",
            onTap: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) =>
                    JoinChatDialog(sendJoinEvent: widget.sendJoinEvent),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget btn({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 50.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.w),
            Icon(
              icon,
              size: 20.w,
              color: Colors.black,
            ),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.w,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取相机信息
  Future<bool> checkCamera() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) {
      return true;
    } else {
      showOpenAppSettingsDialog();
      return false;
    }
  }

  void showOpenAppSettingsDialog() {
    showAnimationDialog(
      context,
      child: CustomAlertDialog(
        title: "相機權限開啟",
        content: "是否前往設置中開啟相機權限",
        btnCancel: "取消",
        btnConfirm: "前往",
        onBtnConfirmTap: () {
          Navigator.of(context).pop();
          openAppSettings();
        },
      ),
    );
  }

  /// 进入扫码页面
  void enterQrScanPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScanView()),
    ).then((value) {
      if (value is String) {
        widget.sendJoinEvent.call(value);
      }
    });
  }
}
