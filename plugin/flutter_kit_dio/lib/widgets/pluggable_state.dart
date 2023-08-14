///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/8/6 11:25
///
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit_dio/ext/extensions.dart';

import '../core/instances.dart';
import '../core/pluggable.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('  ');
const JsonDecoder _decoder = JsonDecoder();

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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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

  /// Data for the [_request].
  dynamic get _requestDataBuilder {
    if (_request.data == null) return null;
    try {
      String data = _encoder.convert(_request.data);
      return _decoder.convert(data);
    } on FormatException catch (_) {
      return _request.data.toString();
    }
  }

  /// Data for the [_response].
  dynamic get _responseDataBuilder {
    if (_response.data == null && _statusCode == 0) {
      return null;
    }
    try {
      String data = _encoder.convert(_response.data);
      return _decoder.convert(data);
    } on FormatException catch (_) {
      return _response.data.toString();
    }
  }

  Widget _detailButton(BuildContext context) {
    return TextButton(
      onPressed: _switchExpand,
      style: _buttonStyle(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              child: DefaultTextEditingShortcuts(
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
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 14),
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        _textEditingController.clear();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.grey,
                      ),
                      iconSize: 20,
                      splashRadius: 20,
                    ),
                  ),
                  onSubmitted: (value) {
                    _searchText.value = value;
                  },
                ),
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
            if (_request.headers.isNotEmpty)
              _DataTable(
                title: '请求头部',
                dataMap: _request.headers,
                searchContent: value,
              ),
            _DataTree(
              title: '响应内容',
              dataMap: _responseDataBuilder,
              searchContent: value,
            ),
            _DataTable(
              title: '响应头部',
              dataMap: _response.headers.map,
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
            _TagText(
              tag: 'Uri',
              content: Uri.decodeFull(_requestUri.toString()),
            ),
            _detailedContent(context),
          ],
        ),
      ),
    );
  }
}

class _DataTree extends StatefulWidget {
  final String title;
  final dynamic dataMap;
  final String searchContent;

  const _DataTree({
    Key? key,
    required this.title,
    required this.dataMap,
    required this.searchContent,
  }) : super(key: key);

  @override
  State<_DataTree> createState() => _DataTreeState();
}

class _DataTreeState extends State<_DataTree> {
  final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(true);

  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (_, bool value, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title(value),
            const SizedBox(height: 8),
            content(value),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  Widget title(bool isExpand) {
    return GestureDetector(
      onTap: () {
        isExpanded.value = !isExpanded.value;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          Icon(
            isExpand ? Icons.arrow_drop_down : Icons.arrow_right,
            color: Colors.black,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget content(bool isExpand) {
    if (!isExpand) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey.shade100,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 36,
          maxWidth: MediaQuery.of(context).size.width * 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _JsonTree(
          valueData: widget.dataMap,
          level: 1,
          lastItem: true,
          searchContent: widget.searchContent,
        ),
      ),
    );
  }
}

class _JsonTree extends StatefulWidget {
  final String? keyData;
  final dynamic valueData;
  final int level;
  final bool lastItem;
  final String searchContent;

  const _JsonTree({
    Key? key,
    this.keyData,
    this.valueData,
    this.level = 0,
    this.lastItem = false,
    this.searchContent = "",
  }) : super(key: key);

  @override
  State<_JsonTree> createState() => _JsonTreeState();
}

class _JsonTreeState extends State<_JsonTree> {
  final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (_, bool value, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: parseJson(value),
        );
      },
    );
  }

  List<Widget> parseJson(bool isExpand) {
    final List<Widget> widgetList = [];
    if (widget.valueData is Map) {
      // 左括号
      widgetList.add(leftParenthesis(
        "{",
        widget.level - 1,
        isExpand,
        keyData: widget.keyData,
      ));
      // 内容
      if (isExpand) {
        int index = 0;
        widget.valueData.forEach((key, value) {
          index++;
          widgetList.add(_JsonTree(
            keyData: key,
            valueData: value,
            level: widget.level + 1,
            lastItem: index == widget.valueData.length,
            searchContent: widget.searchContent,
          ));
        });
      }
      // 右括号
      widgetList.add(rightParenthesis(
        "}${widget.lastItem ? "" : ","}",
        widget.level - 1,
      ));
    } else if (widget.valueData is List) {
      // 左括号
      widgetList.add(leftParenthesis(
        "[",
        widget.level - 1,
        isExpand,
        keyData: widget.keyData,
      ));
      // 内容
      if (isExpand) {
        var listData = (widget.valueData as List);
        for (var i = 0; i < listData.length; i++) {
          widgetList.add(_JsonTree(
            valueData: listData[i],
            level: widget.level + 1,
            lastItem: i == listData.length - 1,
            searchContent: widget.searchContent,
          ));
        }
      }
      // 右括号
      widgetList.add(rightParenthesis(
        "]${widget.lastItem ? "" : ","}",
        widget.level - 1,
      ));
      // 逗号
    } else if (widget.valueData is String) {
      widgetList.add(
        SelectableText.rich(
          TextSpan(children: [
            WidgetSpan(child: SizedBox(width: 20.0 * widget.level, height: 1)),
            TextSpan(
              children: searchText(
                "\"${widget.keyData.toString()}\": ",
                searchContent: widget.searchContent,
                fontColor: Colors.deepOrangeAccent,
              ),
            ),
            TextSpan(
              children: searchText(
                "\"${widget.valueData.toString()}\"",
                searchContent: widget.searchContent,
                fontColor: Colors.blueAccent,
              ),
            ),
            TextSpan(text: widget.lastItem ? "" : ","),
          ]),
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 16,
          ),
        ),
      );
    } else if (widget.valueData is num) {
      widgetList.add(
        SelectableText.rich(
          TextSpan(children: [
            WidgetSpan(child: SizedBox(width: 20.0 * widget.level, height: 1)),
            TextSpan(
              children: searchText(
                "\"${widget.keyData.toString()}\": ",
                searchContent: widget.searchContent,
                fontColor: Colors.deepOrangeAccent,
              ),
            ),
            TextSpan(
              children: searchText(
                widget.valueData.toString(),
                searchContent: widget.searchContent,
                fontColor: Colors.green,
              ),
            ),
            TextSpan(text: widget.lastItem ? "" : ","),
          ]),
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
          ),
        ),
      );
    }

    return widgetList;
  }

  Widget leftParenthesis(String symbol, int level, bool isExpand,
      {String? keyData}) {
    if (level < 0) level = 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 20.0 * level),
        SizedBox(
          width: 20,
          height: 20,
          child: Transform.rotate(
            angle: isExpand ? pi / 2 : 0,
            child: IconButton(
              onPressed: () {
                isExpanded.value = !isExpanded.value;
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 14,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 10,
            ),
          ),
        ),
        SelectableText.rich(
          TextSpan(children: [
            if (keyData != null)
              TextSpan(
                text: "\"$keyData\": ",
                style: const TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontSize: 16,
                ),
              ),
            TextSpan(text: symbol),
          ]),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        Offstage(
          offstage: isExpand,
          child: ColoredBox(
            color: Colors.grey.shade400,
            child: const Text(
              "...",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget rightParenthesis(String symbol, int level) {
    if (level < 0) level = 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 20.0 * (level + 1)),
        SelectableText.rich(
          TextSpan(text: symbol),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ],
    );
  }
}

class _DataTable extends StatefulWidget {
  final String title;
  final Map<String, dynamic> dataMap;
  final String searchContent;

  const _DataTable({
    Key? key,
    required this.title,
    required this.dataMap,
    required this.searchContent,
  }) : super(key: key);

  @override
  State<_DataTable> createState() => _DataTableState();
}

class _DataTableState extends State<_DataTable> {
  final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(true);
  final List<TableRow> rowList = [];

  @override
  Widget build(BuildContext context) {
    initTableRow();
    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (_, bool value, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title(value),
            const SizedBox(height: 8),
            content(value),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  void initTableRow() {
    rowList.clear();
    for (int i = 0; i < widget.dataMap.length; i++) {
      var mapEntries = widget.dataMap.entries.toList();
      String itemKey = mapEntries[i].key.toString();
      String itemValue = mapEntries[i].value.toString();
      rowList.add(TableRow(
        decoration: BoxDecoration(
          color: (i % 2 == 0) ? Colors.grey.shade100 : Colors.grey.shade300,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 2,
            ),
            child: SelectableText.rich(
              TextSpan(
                children: searchText(
                  itemKey,
                  searchContent: widget.searchContent,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            color: Colors.white54,
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SelectableText.rich(
              TextSpan(
                children: searchText(
                  itemValue,
                  searchContent: widget.searchContent,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ));
    }
  }

  Widget title(bool isExpand) {
    return GestureDetector(
      onTap: () {
        isExpanded.value = !isExpanded.value;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          Icon(
            isExpand ? Icons.arrow_drop_down : Icons.arrow_right,
            color: Colors.black,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget content(bool isExpand) {
    if (!isExpand) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: rowList,
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
    disabledForegroundColor: Colors.white,
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
  Color selectedFontColor = Colors.purpleAccent,
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
        backgroundColor:
            map['isHighlight'] ? Colors.grey.shade400 : Colors.transparent,
      ),
    ));
  }
  return textSpanList;
}
