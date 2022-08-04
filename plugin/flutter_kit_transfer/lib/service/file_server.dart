import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:mime/mime.dart';

import '../platform/platform.dart';
import '../utils/file_util.dart';

/// 一个接收文件的服务端
/// Create by Nightmare at 2021/11/21
void Function(double progress, int count)? progressCall;

Future<void> startFileServer(int port) async {
  var server = await HttpServer.bind(
    '0.0.0.0',
    port,
    shared: true,
  );
  server.listen((request) async {
    request.response
      ..headers.add('Access-Control-Allow-Origin', '*')
      ..headers.add('Access-Control-Allow-Headers', '*')
      ..headers.add('Access-Control-Allow-Methods', '*')
      ..headers.add('Access-Control-Allow-Credentials', 'true')
      ..statusCode = HttpStatus.ok;
    if (request.uri.path == '/check_token') {
      request.response.write('web token access');
    } else if (request.uri.path != '/file') {
      request.response
        ..headers.contentType = ContentType.html
        ..write('''<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>

<body>
    <form method="post" action="/file_upload" enctype="multipart/form-data">
        <input type="file" name="file_upload">
        <br>
        <button type="submit">UploadFile</button>
    </form>
</body>
</html>''');
    } else if (request.uri.path == '/file') {
      logD(request.headers);
      List<int> dateBytes = [];
      final fileName = request.headers.value('filename');
      if (fileName != null) {
        String? downPath = '/sdcard/SpeedShare';
        if (GetPlatform.isDesktop) {
          downPath = await getDirectoryPath();
          if (downPath == null) {
            request.response.close();
            return;
          }
        }
        RandomAccessFile randomAccessFile =
            await File(FileUtil.getSafePath('$downPath/$fileName'))
                .open(mode: FileMode.write);
        await for (var data in request) {
          dateBytes.addAll(data);
          progressCall?.call(
            dateBytes.length / request.headers.contentLength,
            dateBytes.length,
          );
          await randomAccessFile.writeFrom(data);
          logW(dateBytes.length / request.headers.contentLength);
        }
        randomAccessFile.close();
        logI('success');
      }
    } else {
      logW(request.headers);
      List<int> dateBytes = [];
      await for (var data in request) {
        dateBytes.addAll(data);
        progressCall?.call(
          dateBytes.length / request.headers.contentLength,
          dateBytes.length,
        );
        logI('dateBytes.length ${dateBytes.length} '
            'request.headers.contentLength -> ${request.headers.contentLength}');
        logW(dateBytes.length / request.headers.contentLength);
      }
      String boundary =
          request.headers.contentType?.parameters['boundary'] ?? '';
      final transformer = MimeMultipartTransformer(boundary);
      final bodyStream = Stream.fromIterable([dateBytes]);
      final parts = await transformer.bind(bodyStream).toList();
      Directory('/sdcard/SpeedShare').createSync(recursive: true);
      for (var part in parts) {
        logI(part.headers);
        final contentDisposition = part.headers['content-disposition'] ?? '';
        logI('contentDisposition -> $contentDisposition');
        final fileName = RegExp(r'filename="([^"]*)"')
            .firstMatch(contentDisposition)
            ?.group(1);
        final content = await part.toList();
        File(FileUtil.getSafePath('/sdcard/SpeedShare/$fileName'))
            .writeAsBytesSync(content[0]);
      }
      logI('success');
    }
    request.response.close();
  });
}
