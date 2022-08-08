import 'dart:io';

import 'package:flutter/material.dart';

import '../config/config.dart';
import '../utils/screen_util.dart';
import '../utils/string_util.dart';

Widget getIconBySuffix(String path) {
  Widget? child;
  if (path.isVideo) {
    child = Image.asset(
      'assets/icon/video.png',
      width: 36.w,
      height: 36.w,
      package: Config.flutterPackage,
    );
  } else if (path.isPdf) {
    child = Image.asset(
      'assets/icon/pdf.png',
      width: 36.w,
      height: 36.w,
      package: Config.flutterPackage,
    );
  } else if (path.isDoc) {
    child = Image.asset(
      'assets/icon/doc.png',
      width: 36.w,
      height: 36.w,
      package: Config.flutterPackage,
    );
  } else if (path.isZip) {
    child = Image.asset(
      'assets/icon/zip.png',
      width: 36.w,
      height: 36.w,
      package: Config.flutterPackage,
    );
  } else if (path.isAudio) {
    child = Image.asset(
      'assets/icon/mp3.png',
      width: 36.w,
      height: 36.w,
      package: Config.flutterPackage,
    );
  } else if (path.isImg) {
    return Hero(
      tag: path,
      child: path.startsWith('http')
          ? Image(
              width: 36.w,
              height: 36.w,
              fit: BoxFit.cover,
              image: ResizeImage(
                NetworkImage(path),
                width: 100,
              ),
            )
          : Image(
              width: 36.w,
              height: 36.w,
              fit: BoxFit.cover,
              image: ResizeImage(
                FileImage(File(path)),
                width: 100,
              ),
            ),
    );
  }

  child ??= Image.asset(
    'assets/icon/other.png',
    width: 36.w,
    height: 36.w,
    package: Config.flutterPackage,
  );
  return GestureDetector(
    onTap: () {
      // if (path.isImg) {
      //   Get.to(
      //     () => PreviewImage(
      //       path: path,
      //       tag: path,
      //     ),
      //   );
      // } else if (path.isVideo) {
      //   Get.to(
      //     () => VideoPreview(
      //       url: path,
      //     ),
      //   );
      // }
    },
    child: child,
  );
}
