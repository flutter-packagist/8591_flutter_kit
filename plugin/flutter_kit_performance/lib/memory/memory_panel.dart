import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';

import 'icon.dart' as icon;
import 'memory_service.dart';

class MemoryPanel extends StatelessWidget implements Pluggable {
  const MemoryPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      home: const _MemoryWidget(),
    );
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'MemoryInfo';

  @override
  String get displayName => '内存使用情况';

  @override
  void onTrigger() {}

  @override
  bool get keepState => false;
}

class _DetailModel {
  final int? count;
  final String? classId;
  final String? className;

  _DetailModel(this.count, this.classId, this.className);
}

class _MemoryWidget extends StatefulWidget {
  const _MemoryWidget({Key? key}) : super(key: key);

  @override
  _MemoryWidgetState createState() => _MemoryWidgetState();
}

class _MemoryWidgetState extends State<_MemoryWidget> {
  final MemoryService _memoryService = MemoryService();

  int _sortColumnIndex = 0;

  bool? _checked = true;

  @override
  void initState() {
    super.initState();
    _memoryService.getInfo(() => setState(() {}));
  }

  void _hidePrivateClass(bool? check) {
    _checked = check;
    _memoryService.hidePrivateClasses(check!);
    setState(() {});
  }

  void _enterDetailPage(_DetailModel detail) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        body: _MemoryDetail(detail: detail, service: _memoryService),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: AppBar(
            elevation: 0.0,
            title: Text(detail.className!),
          ),
        ),
      );
    }));
  }

  Widget _header() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
        child: const Text(
          "VM Info: ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          textAlign: TextAlign.left,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: Text(_memoryService.vmInfo),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 15, bottom: 10),
        child: const Text(
          "Memory Info: ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          textAlign: TextAlign.left,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: Text(_memoryService.memoryUsage),
      ),
      Row(children: [
        const SizedBox(width: 12),
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            value: _checked,
            onChanged: _hidePrivateClass,
          ),
        ),
        const SizedBox(width: 5),
        const Text("Hide private class"),
      ]),
      const SizedBox(height: 10),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: _PerRow(
                    customColor: const Color(0xFFF4F4F4),
                    widgets: [
                      _DropButton(
                        title: "Size",
                        index: 0,
                        stateChanged: (index, descending) =>
                            _memoryService.sort(
                          (d) => d.accumulatedSize,
                          descending,
                          () {
                            _sortColumnIndex = index;
                            setState(() {});
                          },
                        ),
                        showArrow: _sortColumnIndex == 0,
                      ),
                      _DropButton(
                        title: "Count",
                        index: 1,
                        stateChanged: (index, descending) =>
                            _memoryService.sort(
                          (d) => d.instancesAccumulated,
                          descending,
                          () {
                            _sortColumnIndex = index;
                            setState(() {});
                          },
                        ),
                        showArrow: _sortColumnIndex == 1,
                      ),
                      const _DropButton(title: "ClassName")
                    ],
                  ),
                ),
                expandedHeight: 310.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(background: _header()),
              ),
            ];
          },
          body: Scrollbar(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _memoryService.infoList.length,
              itemBuilder: (_, index) {
                var stats = _memoryService.infoList[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _DetailModel detail = _DetailModel(
                      stats.instancesAccumulated,
                      stats.classRef!.id,
                      stats.classRef!.name,
                    );
                    _enterDetailPage(detail);
                  },
                  child: _PerRow(
                    darkColor: index % 2 == 0,
                    widgets: [
                      Text(
                        _memoryService.byteToString(stats.accumulatedSize!),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "${stats.instancesAccumulated}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "${stats.classRef!.name}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

typedef _DropState = void Function(int, bool);

class _DropButton extends StatefulWidget {
  const _DropButton({
    Key? key,
    this.showArrow = false,
    this.descending = true,
    required this.title,
    this.index = 0,
    this.stateChanged,
  }) : super(key: key);

  final bool showArrow;
  final bool descending;
  final int index;
  final String title;
  final _DropState? stateChanged;

  @override
  _DropButtonState createState() => _DropButtonState();
}

class _DropButtonState extends State<_DropButton> {
  bool _descending = false;

  @override
  void initState() {
    super.initState();
    _descending = widget.descending;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.showArrow) {
          _descending = !_descending;
        }
        if (widget.stateChanged != null) {
          widget.stateChanged!(widget.index, _descending);
        }
        setState(() {});
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          widget.showArrow
              ? Icon(_descending ? Icons.arrow_drop_down : Icons.arrow_drop_up)
              : Container()
        ],
      ),
    );
  }
}

class _PerRow extends StatelessWidget {
  const _PerRow({
    Key? key,
    this.widgets,
    this.customColor,
    this.darkColor = false,
  }) : super(key: key);

  final List<Widget>? widgets;
  final bool darkColor;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      color: customColor ??
          (darkColor
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.03)),
      child: Row(
        children: widgets!
            .map(
              (e) => Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: e,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MemoryDetail extends StatefulWidget {
  const _MemoryDetail({
    Key? key,
    required this.detail,
    required this.service,
  }) : super(key: key);

  final _DetailModel detail;

  final MemoryService service;

  @override
  __MemoryDetailState createState() => __MemoryDetailState();
}

class __MemoryDetailState extends State<_MemoryDetail> {
  String _textInfoO = "";
  String _textInfoT = "";

  @override
  void initState() {
    super.initState();

    widget.service.getClassDetailInfo(widget.detail.classId!, (info) {
      StringBuffer buffer = StringBuffer();
      info?.properties?.forEach((element) {
        buffer.writeln(element.propertyStr);
      });
      _textInfoO = buffer.toString();
      StringBuffer bf = StringBuffer();
      info?.functions?.forEach((element) {
        bf.writeln(element);
      });
      _textInfoT = bf.toString();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: _textInfoO.isEmpty && _textInfoT.isEmpty
          ? const Center(
              child: Text(
                'The Object is Sentinel',
                style: TextStyle(fontSize: 20),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: const Text(
                      "Property: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Text(
                    _textInfoO,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: const Text(
                      "Function: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Text(
                    _textInfoT,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
