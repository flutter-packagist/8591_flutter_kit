import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_transfer/model/custom_message.dart';
import 'package:flutter_kit_transfer/utils/file_util.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:get/get.dart';

import '../controller/download_controller.dart';
import '../utils/toast_util.dart';
import 'icon_item.dart';

class TextMessageItem extends StatelessWidget {
  final TextMessage message;
  final bool sendBySelf;

  const TextMessageItem({
    Key? key,
    required this.message,
    required this.sendBySelf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          sendBySelf ? MainAxisAlignment.end : MainAxisAlignment.start,
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
        if (!sendBySelf)
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

class FileMessageItem extends StatelessWidget {
  final FileMessage message;
  final bool sendBySelf;

  const FileMessageItem({
    Key? key,
    required this.message,
    required this.sendBySelf,
  }) : super(key: key);

  DownloadController get controller {
    if (Get.isRegistered<DownloadController>()) {
      return Get.find<DownloadController>();
    }
    return Get.put<DownloadController>(DownloadController());
  }

  String get url => message.url + message.filePath;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          sendBySelf ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        messageBody,
        if (!sendBySelf) messageBtn,
      ],
    );
  }

  Widget get messageBody {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      constraints: BoxConstraints(maxWidth: 200.w),
      child: Column(children: [
        InkWell(
          child: Row(children: [
            getIconBySuffix(url),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message.fileName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.w,
                ),
              ),
            ),
          ]),
        ),
        if (!sendBySelf && !GetPlatform.isWeb) messageProgress,
      ]),
    );
  }

  Widget get messageProgress {
    return GetBuilder<DownloadController>(
      builder: (controller) {
        DownloadInfo downloadInfo = controller.getInfo(url);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 8.w),
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(
                  downloadInfo.progress == 1.0
                      ? Colors.blue
                      : Colors.lightBlueAccent,
                ),
                value: downloadInfo.progress,
              ),
            ),
            SizedBox(height: 4.w),
            Row(children: [
              downloadInfo.progress == 1.0
                  ? Icon(
                      Icons.check,
                      size: 16.w,
                      color: Colors.green,
                    )
                  : Text(
                      '${downloadInfo.speed}/s',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.w,
                      ),
                    ),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: FileUtil.getFileSize(downloadInfo.count)),
                  const TextSpan(text: '/'),
                  TextSpan(text: message.fileSize),
                ]),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.w,
                ),
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget get messageBtn {
    return Column(children: [
      InkWell(
        onTap: () => controller.download(url),
        borderRadius: BorderRadius.circular(8.w),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(
            Icons.file_download,
            size: 18.w,
          ),
        ),
      ),
      InkWell(
        onTap: () async {
          showToast('链接已复制');
          await Clipboard.setData(ClipboardData(text: url));
        },
        borderRadius: BorderRadius.circular(8.w),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(
            Icons.content_copy,
            size: 18.w,
          ),
        ),
      ),
    ]);
  }
}
