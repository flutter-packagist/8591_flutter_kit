import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:flutter_kit_transfer/utils/toast_util.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrcodeDialog extends StatelessWidget {
  final List<String> hostList;
  final int port;

  const QrcodeDialog({
    Key? key,
    required this.hostList,
    required this.port,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 420.w,
          width: 300.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: hostList.length,
                  itemBuilder: (context, index) {
                    String url = 'http://${hostList[index]}:$port';
                    logD("消息服务链接地址: $url");
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: QrImage(
                            data: url,
                            version: QrVersions.auto,
                            size: 280.w,
                          ),
                        ),
                        InkWell(
                          onDoubleTap: () {
                            Clipboard.setData(ClipboardData(text: url))
                                .then((_) => showToast("已复制链接到剪切板"));
                          },
                          child: SelectableText(url),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Text("在浏览器或者其他装有当前应用的\n设备中输入链接，即可进入房间"),
              SizedBox(height: 10.w),
              const Text("左右滑动切换IP地址"),
              SizedBox(height: 20.w),
            ],
          ),
        ),
      ),
    );
  }
}
