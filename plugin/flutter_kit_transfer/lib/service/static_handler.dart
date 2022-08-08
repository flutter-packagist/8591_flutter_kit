import 'dart:async';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';

/// The default resolver for MIME types based on file extensions.
final _defaultMimeTypeResolver = MimeTypeResolver();

/// Creates a shelf [Handler] that serves the file at [path].
///
/// This returns a 404 response for any requests whose [Request.url] doesn't
/// match [url]. The [url] defaults to the basename of [path].
///
/// This uses the given [contentType] for the Content-Type header. It defaults
/// to looking up a content type based on [path]'s file extension, and failing
/// that doesn't sent a [contentType] header at all.
Handler createFileHandler(String path, {String? url, String? contentType}) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ArgumentError.value(path, 'path', 'does not exist.');
  } else if (url != null && !p.url.isRelative(url)) {
    throw ArgumentError.value(url, 'url', 'must be relative.');
  }

  _defaultMimeTypeResolver.addExtension('tgz', 'application/zip');
  final mimeType = contentType ?? _defaultMimeTypeResolver.lookup(path);
  url ??= p.toUri(p.basename(path)).toString();

  return (request) {
    // if (request.url.path != url) return Response.notFound('Not Found');
    return _handleFile(request, file, () => mimeType);
  };
}

/// Serves the contents of [file] in response to [request].
///
/// This handles caching, and sends a 304 Not Modified response if the request
/// indicates that it has the latest version of a file. Otherwise, it calls
/// [getContentType] and uses it to populate the Content-Type header.
Future<Response> _handleFile(Request request, File file,
    FutureOr<String?> Function() getContentType) async {
  final stat = file.statSync();
  final ifModifiedSince = request.ifModifiedSince;

  if (ifModifiedSince != null) {
    final fileChangeAtSecResolution = toSecondResolution(stat.modified);
    if (!fileChangeAtSecResolution.isAfter(ifModifiedSince)) {
      return Response.notModified();
    }
  }

  final contentType = await getContentType();
  final headers = {
    HttpHeaders.lastModifiedHeader: formatHttpDate(stat.modified),
    HttpHeaders.acceptRangesHeader: 'bytes',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Credentials': 'true',
    if (contentType != null) HttpHeaders.contentTypeHeader: contentType,
  };

  if (request.url.queryParameters['download'] == 'true') {
    headers['Content-Disposition'] =
        'attachment;filename=${p.toUri(p.basename(file.path))}';
  }
  return _fileRangeResponse(request, file, headers) ??
      Response.ok(
        request.method == 'HEAD' ? null : file.openRead(),
        headers: headers..[HttpHeaders.contentLengthHeader] = '${stat.size}',
      );
}

/// Serves a range of [file], if [request] is valid 'bytes' range request.
///
/// If the request does not specify a range, specifies a range of the wrong
/// type, or has a syntactic error the range is ignored and `null` is returned.
///
/// If the range request is valid but the file is not long enough to include the
/// start of the range a range not satisfiable response is returned.
///
/// Ranges that end past the end of the file are truncated.
Response? _fileRangeResponse(
    Request request, File file, Map<String, Object> headers) {
  final range = request.headers[HttpHeaders.rangeHeader];
  if (range == null) return null;
  final matches = RegExp(r'^bytes=(\d*)\-(\d*)$').firstMatch(range);
  // Ignore ranges other than bytes
  if (matches == null) return null;

  final actualLength = file.lengthSync();
  final startMatch = matches[1]!;
  final endMatch = matches[2]!;
  if (startMatch.isEmpty && endMatch.isEmpty) return null;

  int start; // First byte position - inclusive.
  int end; // Last byte position - inclusive.
  if (startMatch.isEmpty) {
    start = actualLength - int.parse(endMatch);
    if (start < 0) start = 0;
    end = actualLength - 1;
  } else {
    start = int.parse(startMatch);
    end = endMatch.isEmpty ? actualLength - 1 : int.parse(endMatch);
  }

  // If the range is syntactically invalid the Range header
  // MUST be ignored (RFC 2616 section 14.35.1).
  if (start > end) return null;

  if (end >= actualLength) {
    end = actualLength - 1;
  }
  if (start >= actualLength) {
    return Response(
      HttpStatus.requestedRangeNotSatisfiable,
      headers: headers,
    );
  }
  return Response(
    HttpStatus.partialContent,
    body: request.method == 'HEAD' ? null : file.openRead(start, end + 1),
    headers: headers
      ..[HttpHeaders.contentLengthHeader] = (end - start + 1).toString()
      ..[HttpHeaders.contentRangeHeader] = 'bytes $start-$end/$actualLength',
  );
}

DateTime toSecondResolution(DateTime dt) {
  if (dt.millisecond == 0) return dt;
  return dt.subtract(Duration(milliseconds: dt.millisecond));
}
