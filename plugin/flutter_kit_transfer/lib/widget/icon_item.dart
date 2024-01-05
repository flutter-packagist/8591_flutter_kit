import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../config/config.dart';
import '../utils/screen_util.dart';
import '../utils/string_util.dart';

Widget getIconBySuffix(String path, Uint8List? bytes) {
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
    if (path.startsWith('http')) {
      child = Image(
        width: 36.w,
        height: 36.w,
        fit: BoxFit.cover,
        image: ResizeImage(
          NetworkImage(path),
          width: 100,
        ),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 36.w,
            height: 36.w,
            color: Colors.grey.shade400,
          );
        },
      );
    } else if (bytes != null) {
      child = Image(
        width: 36.w,
        height: 36.w,
        fit: BoxFit.cover,
        image: ResizeImage(
          MemoryImage(bytes),
          width: 100,
        ),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 36.w,
            height: 36.w,
            color: Colors.grey.shade400,
          );
        },
      );
    } else {
      child = Image(
        width: 36.w,
        height: 36.w,
        fit: BoxFit.cover,
        image: ResizeImage(
          FileImage(File(path)),
          width: 100,
        ),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 36.w,
            height: 36.w,
            color: Colors.grey.shade400,
          );
        },
      );
    }
    return Hero(tag: path, child: child);
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
