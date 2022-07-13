import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit_log/log/log_data.dart';
import 'package:tuple/tuple.dart';

import 'console_manager.dart';
import 'date_time_style.dart';
import 'icon.dart' as icon;

const dateTimeStyleKey = "console_panel_datetime_style";

class Console extends StatefulWidget implements PluggableWithStream {
  Console({Key? key}) : super(key: key) {
    ConsoleManager.redirectDebugPrint();
  }

  @override
  ConsoleState createState() => ConsoleState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'Console';

  @override
  String get displayName => '控制台';

  @override
  void onTrigger() {}

  @override
  Stream get stream => ConsoleManager.streamController!.stream;

  @override
  StreamFilter get streamFilter => (e) => true;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);
}

class ConsoleState extends State<Console>
    with WidgetsBindingObserver, StoreMixin {
  final TextEditingController textEditingController = TextEditingController();
  final TextStyle inputTextStyle =
      const TextStyle(fontSize: 14, color: Colors.white, height: 1.3);
  List<Tuple2<DateTime, LogData>> _logList = <Tuple2<DateTime, LogData>>[];
  StreamSubscription? _subscription;
  ScrollController? _controller;
  DateTimeStyle? _dateTimeStyle;
  RegExp? _filterExp;

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller = null;
    _dateTimeStyle = DateTimeStyle.time;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _dateTimeStyle = DateTimeStyle.none;
    fetchWithKey(dateTimeStyleKey).then((value) async {
      if (value != null && value is int) {
        _dateTimeStyle = styleById(value);
      } else {
        _dateTimeStyle = DateTimeStyle.datetime;
        await storeWithKey(dateTimeStyleKey, idByStyle(_dateTimeStyle!));
      }
      setState(() {});
    });
    _controller = ScrollController();
    _logList = ConsoleManager.logData.toList().reversed.toList();
    _subscription = ConsoleManager.streamController!.stream.listen((onData) {
      if (mounted) {
        if (_filterExp != null) {
          _logList = ConsoleManager.logData
              .where((e) {
                return _filterExp!.hasMatch(e.item1.toString()) ||
                    _filterExp!.hasMatch(e.item2.lowerCaseText);
              })
              .toList()
              .reversed
              .toList();
        } else {
          _logList = ConsoleManager.logData.toList().reversed.toList();
        }

        setState(() {});
        Future.delayed(const Duration(milliseconds: 200), () {
          _controller!.animateTo(
            _controller!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller!.animateTo(
        _controller!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      ); // 22 i
    });
  }

  void _refreshConsole() {
    if (_filterExp != null) {
      _logList = ConsoleManager.logData.where((e) {
        return _filterExp!.hasMatch(e.item1.toString()) ||
            _filterExp!.hasMatch(e.item2.lowerCaseText);
      }).toList();
    } else {
      _logList = ConsoleManager.logData.toList();
    }
  }

  String _dateTimeString(int logIndex) {
    String result = '';
    switch (_dateTimeStyle) {
      case DateTimeStyle.datetime:
        result = _logList[_logList.length - logIndex - 1]
            .item1
            .toString()
            .padRight(26, '0');
        break;
      case DateTimeStyle.time:
        result = _logList[_logList.length - logIndex - 1]
            .item1
            .toString()
            .padRight(26, '0')
            .substring(11);
        break;
      case DateTimeStyle.timestamp:
        result = _logList[_logList.length - logIndex - 1]
            .item1
            .millisecondsSinceEpoch
            .toString();
        break;
      case DateTimeStyle.none:
        result = '';
        break;
      default:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      actions: [
        __changeDateTimeStyleButton(context),
        _clearAllButton(context),
      ],
      child: ColoredBox(
        color: Colors.black,
        child: Column(children: [
          Expanded(child: consoleListView()),
          filterTextField(),
        ]),
      ),
    );
  }

  Widget __changeDateTimeStyleButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        _dateTimeStyle = styleById((idByStyle(_dateTimeStyle!) + 1) % 4);
        await storeWithKey(dateTimeStyleKey, idByStyle(_dateTimeStyle!));
        setState(() {});
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(
            Icons.change_circle_outlined,
            size: 16,
            color: Colors.black,
          ),
          SizedBox(width: 4),
          Text(
            '切换时间样式',
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _clearAllButton(BuildContext context) {
    return TextButton(
      onPressed: ConsoleManager.clearLog,
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

  Widget consoleListView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1600,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          controller: _controller,
          itemCount: _logList.length,
          itemBuilder: (context, index) {
            var logEntry = _logList[index];
            return RichText(
              key: Key(logEntry.item2.id.toString()),
              strutStyle: const StrutStyle(
                fontFamily: 'Courier',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
              text: TextSpan(children: [
                TextSpan(text: _dateTimeString(index)),
                const TextSpan(text: "  "),
                logEntry.item2.span,
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget filterTextField() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: textEditingController,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _filterExp = RegExp(value);
              } else {
                _filterExp = null;
              }
              setState(() {});
              _refreshConsole();
            },
            maxLines: 1,
            style: inputTextStyle,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixText: "\$ ",
              prefixStyle: inputTextStyle,
              hintText: "输入要过滤的内容",
              hintStyle: inputTextStyle,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: () {
            textEditingController.clear();
            _filterExp = null;
            setState(() {});
            _refreshConsole();
          },
        ),
      ]),
    );
  }
}
