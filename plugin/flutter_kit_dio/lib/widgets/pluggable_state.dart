///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 11:25
///
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit_dio/ext/extensions.dart';

import '../core/instances.dart';
import '../core/pluggable.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

class DioPluggableState extends State<DioInspector> {
  @override
  void initState() {
    super.initState();
    // Bind listener to refresh requests.
    InspectorInstance.httpContainer.addListener(_listener);
  }

  @override
  void dispose() {
    InspectorInstance.httpContainer
      ..removeListener(_listener) // First, remove refresh listener.
      ..resetPaging(); // Then reset the paging field.
    super.dispose();
  }

  /// Using [setState] won't cause too much performance regression,
  /// since we've implemented the list with `findChildIndexCallback`.
  void _listener() {
    Future.microtask(() {
      if (mounted &&
          !context.debugDoingBuild &&
          context.owner?.debugBuilding != true) {
        setState(() {});
      }
    });
  }

  Widget _collapseAllButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        final List<Response<dynamic>> requests =
            InspectorInstance.httpContainer.requests;
        for (var response in requests) {
          response.isExpand = false;
        }
        setState(() {});
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(
            Icons.compress,
            size: 14,
            color: Colors.black,
          ),
          SizedBox(width: 4),
          Text(
            '收起',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _clearAllButton(BuildContext context) {
    return TextButton(
      onPressed: InspectorInstance.httpContainer.clearRequests,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(
            Icons.cleaning_services,
            size: 14,
            color: Colors.black,
          ),
          SizedBox(width: 4),
          Text(
            '清空',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _itemList(BuildContext context) {
    final List<Response<dynamic>> requests =
        InspectorInstance.httpContainer.pagedRequests;
    final int length = requests.length;
    if (length > 0) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: length,
        itemBuilder: (context, index) {
          final Response<dynamic> r = requests[index];
          if (index == length - 2) {
            InspectorInstance.httpContainer.loadNextPage();
          }
          return _ResponseCard(
            key: ValueKey<int>(r.startTimeMilliseconds),
            response: r,
          );
        },
      );
    }
    return const Center(
      child: Text(
        '当前暂无网络请求\n┐(ﾟ～ﾟ)┌',
        style: TextStyle(fontSize: 20, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      actions: [
        _collapseAllButton(context),
        _clearAllButton(context),
      ],
      child: ColoredBox(
        color: Colors.white,
        child: _itemList(context),
      ),
    );
  }
}

class _ResponseCard extends StatefulWidget {
  const _ResponseCard({
    required Key? key,
    required this.response,
  }) : super(key: key);

  final Response<dynamic> response;

  @override
  _ResponseCardState createState() => _ResponseCardState();
}

class _ResponseCardState extends State<_ResponseCard> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchText = ValueNotifier<String>("");
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _isExpanded.dispose();
    _searchText.dispose();
    super.dispose();
  }

  void _switchExpand() {
    _isExpanded.value = !_isExpanded.value;
    _response.isExpand = _isExpanded.value;
  }

  Response<dynamic> get _response => widget.response;

  RequestOptions get _request => _response.requestOptions;

  /// The end time for the [_response].
  bool get isExpand => _response.isExpand;

  /// The start time for the [_request].
  DateTime get _startTime => _response.startTime;

  /// The end time for the [_response].
  DateTime get _endTime => _response.endTime;

  /// The duration between the request and the response.
  Duration get _duration => _endTime.difference(_startTime);

  /// Status code for the [_response].
  int get _statusCode => _response.statusCode ?? 0;

  /// Colors matching status.
  Color get _statusColor {
    if (_statusCode >= 200 && _statusCode < 300) {
      return Colors.lightGreen;
    }
    if (_statusCode >= 300 && _statusCode < 400) {
      return Colors.orangeAccent;
    }
    if (_statusCode >= 400 && _statusCode < 500) {
      return Colors.purple;
    }
    if (_statusCode >= 500 && _statusCode < 600) {
      return Colors.red;
    }
    return Colors.blueAccent;
  }

  /// The method that the [_request] used.
  String get _method => _request.method;

  /// The [Uri] that the [_request] requested.
  Uri get _requestUri => _request.uri;

  /// Header for the [_request].
  String? get _requestHeaderBuilder {
    if (_request.headers.isEmpty) return null;
    var stringBuffer = StringBuffer();
    _request.headers.forEach((key, value) {
      value.forEach((e) => stringBuffer.writeln('$key: $e'));
    });
    return stringBuffer.toString();
  }

  /// Data for the [_request].
  String? get _requestDataBuilder {
    if (_request.data == null) return null;
    try {
      return _encoder.convert(_request.data);
    } on FormatException catch (_) {
      return _request.data;
    }
  }

  /// Data for the [_response].
  String get _responseDataBuilder {
    if (_response.data == null && _statusCode == 0) {
      return "链接解析失败";
    }
    try {
      return _encoder.convert(_response.data);
    } on FormatException catch (_) {
      return _response.data;
    }
  }

  Widget _detailButton(BuildContext context) {
    return TextButton(
      onPressed: _switchExpand,
      style: _buttonStyle(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search, size: 16, color: Colors.white),
          Text(
            '详情',
            style: TextStyle(fontSize: 12, color: Colors.white, height: 1.2),
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _infoContent(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(_startTime.hms()),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _statusColor,
          ),
          child: Text(
            _statusCode.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _method,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _duration.inMilliseconds > 500
                ? Colors.redAccent.shade100
                : Colors.white,
          ),
          child: Text('${_duration.inMilliseconds}ms'),
        ),
        const Spacer(),
        _detailButton(context),
      ],
    );
  }

  Widget _detailedContent(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (_, bool value, __) {
        if (!value) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                minLines: 1,
                maxLines: 1,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                cursorWidth: 1.5,
                cursorColor: Colors.blue,
                controller: _textEditingController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefix: const Padding(padding: EdgeInsets.only(left: 18)),
                  suffix: const Padding(padding: EdgeInsets.only(left: 18)),
                  hintText: "请输入搜索文本",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: (value) {
                  _searchText.value = value;
                },
              ),
            ),
            _detailedText(),
          ],
        );
      },
    );
  }

  Widget _detailedText() {
    return ValueListenableBuilder<String>(
      valueListenable: _searchText,
      builder: (_, String value, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_requestDataBuilder != null)
              _TagText(
                tag: '请求参数',
                content: '\n$_requestDataBuilder',
                searchContent: value,
              ),
            if (_requestHeaderBuilder != null)
              _TagText(
                tag: '请求头部',
                content: '\n$_requestHeaderBuilder',
                searchContent: value,
              ),
            _TagText(
              tag: '响应内容',
              content: '\n$_responseDataBuilder',
              searchContent: value,
            ),
            _TagText(
              tag: '响应头部',
              content: '\n${_response.headers}',
              searchContent: value,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _isExpanded.value = _response.isExpand;
    return Card(
      margin: const EdgeInsets.all(8.0),
      shadowColor: Theme.of(context).canvasColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _infoContent(context),
            const SizedBox(height: 10),
            _TagText(tag: 'Uri', content: '$_requestUri'),
            _detailedContent(context),
          ],
        ),
      ),
    );
  }
}

class _TagText extends StatelessWidget {
  const _TagText({
    Key? key,
    required this.tag,
    required this.content,
    this.searchContent = '',
    this.selectable = true,
  }) : super(key: key);

  final String tag;
  final String content;
  final String searchContent;
  final bool selectable;

  TextSpan get span {
    List<TextSpan> textSpanList =
        searchText(content, searchContent: searchContent);
    textSpanList.insert(
      0,
      TextSpan(
        text: '$tag: ',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
    return TextSpan(children: textSpanList);
  }

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (selectable) {
      text = SelectableText.rich(
        span,
        style: const TextStyle(height: 1.5),
      );
    } else {
      text = Text.rich(
        span,
        style: const TextStyle(height: 1.5),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: text,
    );
  }
}

extension _StringExtension on String {
  String get notBreak => Characters(this).toList().join('\u{200B}');
}

extension _DateTimeExtension on DateTime {
  String hms([String separator = ':']) => '$hour$separator'
      '${'$minute'.padLeft(2, '0')}$separator'
      '${'$second'.padLeft(2, '0')}';
}

ButtonStyle _buttonStyle(
  BuildContext context, {
  EdgeInsetsGeometry? padding,
}) {
  return TextButton.styleFrom(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    minimumSize: Size.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999999),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    primary: Colors.white,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

/// searchContent       输入的搜索内容
/// textContent         需要显示的文字内容
/// prefixContent       需要另外添加在最前面的文字
/// fontSize            需要显示的字体大小
/// fontColor           需要显示的正常字体颜色
/// selectedFontColor   需要显示的搜索字体颜色
List<TextSpan> searchText(
  String textContent, {
  String searchContent = '',
  String prefixContent = '',
  double fontSize = 16,
  Color fontColor = Colors.black,
  Color selectedFontColor = Colors.blue,
}) {
  List<TextSpan> textSpanList = [];

  // 添加前缀文本
  if (prefixContent.isNotEmpty) {
    textSpanList.add(TextSpan(
      text: prefixContent,
      style: TextStyle(
        fontSize: fontSize,
        color: fontColor,
      ),
    ));
  }

  // 不包含搜索内容时，直接返回原文
  if (searchContent.isEmpty || !textContent.contains(searchContent)) {
    textSpanList.add(TextSpan(
      text: textContent,
      style: TextStyle(
        fontSize: fontSize,
        color: fontColor,
      ),
    ));
    return textSpanList;
  }

  List<Map<String, dynamic>> textMapList = [];
  bool isContainsSearchText = true;
  while (isContainsSearchText) {
    int startIndex = textContent.indexOf(searchContent);
    int endIndex = startIndex + searchContent.length;
    String searchText = textContent.substring(startIndex, endIndex);

    Map<String, dynamic> highlightTextMap = {};
    if (startIndex > 0) {
      String normalText = textContent.substring(0, startIndex);
      highlightTextMap = {};
      highlightTextMap['content'] = normalText;
      highlightTextMap['isHighlight'] = false;
      textMapList.add(highlightTextMap);
    }
    highlightTextMap = {};
    highlightTextMap['content'] = searchText;
    highlightTextMap['isHighlight'] = true;
    textMapList.add(highlightTextMap);

    textContent = textContent.substring(endIndex, textContent.length);
    isContainsSearchText = textContent.contains(searchContent);
    if (!isContainsSearchText && textContent.isNotEmpty) {
      highlightTextMap = {};
      highlightTextMap['content'] = textContent;
      highlightTextMap['isHighlight'] = false;
      textMapList.add(highlightTextMap);
    }
  }

  for (var map in textMapList) {
    textSpanList.add(TextSpan(
      text: map['content'],
      style: TextStyle(
        fontSize: fontSize,
        color: map['isHighlight'] ? selectedFontColor : fontColor,
      ),
    ));
  }
  return textSpanList;
}
