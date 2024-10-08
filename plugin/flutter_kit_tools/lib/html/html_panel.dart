import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  late WebViewController webViewController;
  final TextEditingController textEditingController =
      TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    initWebViewController();
  }

  void initWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      (webViewController.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool isCanBack = await webViewController.canGoBack();
        if (isCanBack) {
          await webViewController.goBack();
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
              Expanded(child: webView),
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
        style: TextStyle(color: Colors.grey.shade50, fontSize: 14),
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
    return WebViewWidget(
      controller: webViewController,
    );
  }

  void onSearchTap() async {
    Uri uri = Uri.parse(textEditingController.text);
    await webViewController.loadRequest(uri);
  }
}
