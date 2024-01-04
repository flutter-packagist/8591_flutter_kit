// 用来快速判断文件的类型
import 'package:file_saver/file_saver.dart';

extension StringExt on String {
  bool get isAudio {
    return endsWith('.mp3') || endsWith('.flac') || endsWith('.aac');
  }

  bool get isVideo {
    return endsWith('.mp4') ||
        endsWith('.mkv') ||
        endsWith('.mov') ||
        endsWith(".avi") ||
        endsWith(".wmv") ||
        endsWith(".rmvb") ||
        endsWith(".mpg") ||
        endsWith(".3gp");
  }

  bool get isApk {
    return endsWith('.apk');
  }

  bool get isImg {
    return endsWith('.gif') ||
        endsWith('.jpg') ||
        endsWith('.jpeg') ||
        endsWith('.png') ||
        endsWith('.webp');
  }

  bool get isDoc {
    return toLowerCase().endsWith('.doc') ||
        endsWith('.docx') ||
        endsWith('.ppt') ||
        endsWith('.pptx') ||
        endsWith('.xls') ||
        endsWith('.xlsx') ||
        endsWith('.pdf');
  }

  bool get isText {
    return toLowerCase().endsWith('.txt') || endsWith('.md');
  }

  bool get isPdf {
    return endsWith('.pdf');
  }

  bool get isZip {
    return endsWith('.zip') || endsWith('.7z') || endsWith('.rar');
  }

  String get getType {
    if (isAudio) {
      return '音乐';
    } else if (isVideo) {
      return '视频';
    } else if (isImg) {
      return '图片';
    } else if (isPdf || isDoc) {
      return '文档';
    } else if (isZip) {
      return '压缩包';
    } else if (isApk) {
      return '安装包';
    }
    return '未知';
  }

  String get getDirectory {
    if (isAudio) {
      return 'music';
    } else if (isVideo) {
      return 'video';
    } else if (isImg) {
      return 'image';
    } else if (isPdf || isDoc) {
      return 'document';
    } else if (isZip) {
      return 'zip';
    } else if (isApk) {
      return 'apk';
    }
    return 'others';
  }

  String get getFileName {
    return split('/').last.split('.').first;
  }

  String get getFileExt {
    return toLowerCase().split('.').last;
  }

  MimeType get getMimeType {
    if (getFileExt == 'mp3') {
      return MimeType.mp3;
    } else if (getFileExt == 'flac') {
      return MimeType.custom;
    } else if (getFileExt == 'aac') {
      return MimeType.aac;
    } else if (getFileExt == 'mp4') {
      return MimeType.mpeg;
    } else if (getFileExt == 'mkv') {
      return MimeType.custom;
    } else if (getFileExt == 'mov') {
      return MimeType.custom;
    } else if (getFileExt == 'avi') {
      return MimeType.avi;
    } else if (getFileExt == 'wmv') {
      return MimeType.custom;
    } else if (getFileExt == 'rmvb') {
      return MimeType.custom;
    } else if (getFileExt == 'mpg') {
      return MimeType.custom;
    } else if (getFileExt == '3gp') {
      return MimeType.custom;
    } else if (getFileExt == 'apk') {
      return MimeType.custom;
    } else if (getFileExt == 'gif') {
      return MimeType.gif;
    } else if (getFileExt == 'jpg' || getFileExt == 'jpeg') {
      return MimeType.jpeg;
    } else if (getFileExt == 'png') {
      return MimeType.png;
    } else if (getFileExt == 'webp') {
      return MimeType.custom;
    } else if (getFileExt == 'doc' || getFileExt == 'docx') {
      return MimeType.microsoftWord;
    } else if (getFileExt == 'ppt' || getFileExt == 'pptx') {
      return MimeType.microsoftPresentation;
    } else if (getFileExt == 'xls' || getFileExt == 'xlsx') {
      return MimeType.microsoftExcel;
    } else if (getFileExt == 'pdf') {
      return MimeType.pdf;
    } else if (getFileExt == 'txt') {
      return MimeType.text;
    } else if (getFileExt == 'md') {
      return MimeType.custom;
    } else if (getFileExt == 'zip') {
      return MimeType.zip;
    } else if (getFileExt == '7z') {
      return MimeType.custom;
    } else if (getFileExt == 'rar') {
      return MimeType.custom;
    }
    return MimeType.custom;
  }

  String get getCustomMimeType {
    if (getFileExt == 'flac') {
      return "audio/flac";
    } else if (getFileExt == 'mkv') {
      return "video/x-matroska";
    } else if (getFileExt == 'mov') {
      return "video/quicktime";
    } else if (getFileExt == 'wmv') {
      return "video/x-ms-wmv";
    } else if (getFileExt == 'rmvb') {
      return "application/vnd.rn-realmedia-vbr";
    } else if (getFileExt == 'mpg') {
      return "video/mpeg";
    } else if (getFileExt == '3gp') {
      return "video/mp4";
    } else if (getFileExt == 'apk') {
      return "application/vnd.android.package-archive";
    } else if (getFileExt == 'webp') {
      return "image/webp";
    } else if (getFileExt == 'md') {
      return "text/markdown";
    } else if (getFileExt == '7z') {
      return "application/x-7z-compressed";
    } else if (getFileExt == 'rar') {
      return "application/vnd.rar";
    }
    return "unknown";
  }
}
