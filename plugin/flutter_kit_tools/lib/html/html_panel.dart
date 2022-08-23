import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'icon.dart' as icon;

class HtmlPanel extends StatefulWidget implements Pluggable {
  const HtmlPanel({Key? key}) : super(key: key);

  @override
  HtmlPanelState createState() => HtmlPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'html';

  @override
  String get displayName => 'H5任意门';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  bool get keepState => false;
}

class HtmlPanelState extends State<HtmlPanel> {
  final Completer<WebViewController> webViewController =
      Completer<WebViewController>();
  final TextEditingController textEditingController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var webController = await webViewController.future;
        bool isCanBack = await webController.canGoBack();
        if (isCanBack) {
          await webController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        home: Scaffold(
          backgroundColor: Colors.grey.shade400,
          body: SafeArea(
            child: Column(children: [
              textField,
              Expanded(
                child: ColoredBox(
                  color: Colors.white,
                  child: Stack(children: [
                    webView,
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget get textField {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "请输入网址",
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
        onChanged: (text) {},
        onSubmitted: (value) => onSearchTap(),
      ),
    );
  }

  Widget get webView {
    return WebView(
      initialUrl: "",
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController controller) {
        webViewController.complete(controller);
      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  Widget get listHint {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Center();
      },
    );
  }

  void onSearchTap() async {
    var webController = await webViewController.future;
    await webController.loadUrl(textEditingController.text);
  }
}
