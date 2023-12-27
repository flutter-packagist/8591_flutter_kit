import 'dart:io';

import 'package:flutter_kit_transfer/utils/dio_util.dart';
import 'package:flutter_kit_transfer/utils/file_util.dart';
import 'package:flutter_kit_transfer/utils/string_util.dart';
import 'package:flutter_kit_transfer/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DownloadController extends GetxController {
  // key是url，value是进度
  Map<String, DownloadInfo> progressMap = {};

  DownloadInfo getInfo(String url) {
    if (progressMap.containsKey(url)) {
      return progressMap[url] ?? DownloadInfo();
    }
    return DownloadInfo();
  }

  Future<void> downloadFile(String directory, String url) async {
    if (progressMap.containsKey(url) && progressMap[url]?.progress != 0.0) {
      showToast("正在下载中...");
      return;
    }
    if (progressMap.containsKey(url) && progressMap[url]?.progress == 1.0) {
      showToast("下载完成！");
      return;
    }
    DownloadInfo downloadInfo = DownloadInfo();
    progressMap[url] = downloadInfo;
    String savePath = "$directory/${url.getDirectory}/${basename(url)}";
    savePath = FileUtil.getSafePath(savePath);

    await httpInstance.download(
      "$url?download=true",
      savePath,
      onReceiveProgress: (count, total) {
        downloadInfo.count = count;
        downloadInfo.progress = count / total;
        update();
      },
    );
  }

  Future<void> download(String url) async {
    if (GetPlatform.isWeb) {
      if (await canLaunchUrlString(url)) {
        await launchUrlString('$url?download=true');
        return;
      }
    } else if (GetPlatform.isMobile) {

    } else if (GetPlatform.isDesktop) {

    }
    showToast("当前操作系统不支持下载，请联系开发者");
  }

  Future<String> getMobileLocalPath() async {
    Directory? directory;
    if (GetPlatform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (GetPlatform.isAndroid) {
      directory = await getExternalStorageDirectory();
    }
    if (directory != null) return directory.path;
    showToast("getMobileLocalPath 只支持android和ios");
    return "";
  }
}

class DownloadInfo {
  double progress = 0;
  String speed = '0';
  int count = 0;
}
