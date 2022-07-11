import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit_code/service/code_search_service.dart';
import 'package:flutter_kit_code/util/syntax_highlighter.dart';

import 'icon.dart' as icon;
import 'icon_text.dart';

class CodeDisplayPanel extends StatefulWidget implements Pluggable {
  const CodeDisplayPanel({Key? key}) : super(key: key);

  @override
  CodeDisplayPanelState createState() => CodeDisplayPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'CodeDisplayPanel';

  @override
  String get displayName => '查看代码';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);
}

class CodeDisplayPanelState extends State<CodeDisplayPanel>
    with
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Tab> tabs = const [
    Tab(child: IconText(text: "文件", icon: Icons.find_in_page)),
    Tab(child: IconText(text: "代码", icon: Icons.code)),
  ];
  late TabController tabController;
  late TextEditingController textEditingController;
  Map<String?, String?>? scriptMap = {};
  String curPath = "";
  String? codeContent = "";

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);
    textEditingController = TextEditingController(text: "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ConsolePanel(
      child: ColoredBox(
        color: Colors.white,
        child: Column(children: [
          ColoredBox(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: tabs,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                filePanel(),
                codePanel(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget filePanel() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "当前路径（点击以编辑，支持部分匹配）：",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "请输入路径",
              border: InputBorder.none,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Offstage(
                    offstage: textEditingController.text.isEmpty,
                    child: IconButton(
                      onPressed: () => textEditingController.clear(),
                      icon: const Icon(Icons.clear, size: 20),
                    ),
                  ),
                  IconButton(
                    onPressed: onSearchTap,
                    icon: const Icon(Icons.search, size: 20),
                  ),
                ],
              ),
            ),
            controller: textEditingController,
            style: const TextStyle(color: Colors.blue, fontSize: 14),
            maxLines: 5,
            minLines: 1,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.search,
            onChanged: (text) {
              setState(() {});
            },
            onSubmitted: (value) => onSearchTap(),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: scriptMap?.keys.length ?? 0,
              itemBuilder: (context, index) {
                // curPath = scriptMap?.values.elementAt(index) ?? "";
                // curPath = Uri.decodeFull(curPath);
                // int firstIndex = curPath.indexOf("scripts/");
                // int lastIndex = curPath.lastIndexOf("/");
                // String url = curPath.substring(firstIndex + 8, lastIndex);
                curPath = scriptMap?.keys.elementAt(index) ?? "";
                String url = curPath;
                return GestureDetector(
                  onTap: () => onLinkTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      url,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget codePanel() {
    const double textScaleFactor = 1.0;
    final SyntaxHighlighterStyle style =
        Theme.of(context).brightness == Brightness.dark
            ? SyntaxHighlighterStyle.darkThemeStyle()
            : SyntaxHighlighterStyle.lightThemeStyle();
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0)
                .apply(fontSizeFactor: textScaleFactor),
            children: <TextSpan>[
              DartSyntaxHighlighter(style).format(codeContent ?? ""),
            ],
          ),
          style: DefaultTextStyle.of(context)
              .style
              .apply(fontSizeFactor: textScaleFactor),
        ),
      ),
    );
  }

  void onSearchTap() async {
    scriptMap = await CodeSearchService()
        .getScriptIdsWithKeyword(textEditingController.text);
    setState(() {});
  }

  void onLinkTap(int index) async {
    tabController.animateTo(1);
    String scriptId = scriptMap?.values.elementAt(index) ?? "";
    codeContent = await CodeSearchService().getSourceCodeWithScriptId(scriptId);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {});
    });
  }
}
