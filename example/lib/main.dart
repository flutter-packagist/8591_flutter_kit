import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/core/plugin_manager.dart';
import 'package:flutter_kit/widget/root_widget.dart';
import 'package:flutter_kit_code/widget/code_display_panel.dart';
import 'package:flutter_kit_device/cpu_info/cpu_info_panel.dart';
import 'package:flutter_kit_device/device_info/device_info_panel.dart';
import 'package:flutter_kit_dio/core/pluggable.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:flutter_kit_performance/flutter_kit_performance.dart';
import 'package:flutter_kit_tools/flutter_kit_tools.dart';
import 'package:flutter_kit_transfer/widget/transfer_panel.dart';

final Dio dio = Dio()..options = BaseOptions(connectTimeout: 10000);

void main() {
  PluginManager()
    ..registerAll([
      DioInspector(dio: dio),
      const Console(),
      const CpuInfoPanel(),
      const DeviceInfoPanel(),
      const ColorPicker(),
      const TransferPanel(packageName: "com.example.example"),
      const SettingPanel(),
      const HtmlPanel(),
    ])
    ..registerDebugOnly([
      const CodeDisplayPanel(),
      const MemoryPanel(),
      const Performance(),
    ]);
  runApp(const KitWidget(enable: true, child: MyApp()));
  setupSystemChrome();
}

void setupSystemChrome() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarDividerColor: null,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            btnNetworkRequest(),
            const SizedBox(height: 20),
            btnLogPrint(),
            const SizedBox(height: 20),
            btnNetworkHtml(),
          ],
        ),
      ),
    );
  }

  Widget btnNetworkRequest() {
    return TextButton(
      onPressed: () {
        Future.wait<void>(
          List<Future<void>>.generate(
            10,
            (int i) {
              if (i % 2 == 0) {
                return Future<void>.delayed(
                  Duration(seconds: i),
                  () => dio.get(
                    'https://api.github11.com'
                    '/?_t=${DateTime.now().millisecondsSinceEpoch}&$i',
                  ),
                );
              } else {
                return Future<void>.delayed(
                  Duration(seconds: i),
                  () => dio.get(
                    'https://api.github.com'
                    '/?_t=${DateTime.now().millisecondsSinceEpoch}&$i',
                  ),
                );
              }
            },
          ),
        );
      },
      child: const Text('网络请求测试'),
    );
  }

  Widget btnLogPrint() {
    return TextButton(
      onPressed: () {
        Future.wait<void>(
          List<Future<void>>.generate(
            10,
            (int i) => Future<void>.delayed(
              Duration(seconds: i),
              () {
                switch (i) {
                  case 0:
                    logV("冗余信息，Release模式下不输出");
                    break;
                  case 1:
                    logD("调试信息，Release模式下不输出");
                    break;
                  case 2:
                    logI("提示信息，Release模式下会输出");
                    break;
                  case 3:
                    logW("警告信息，Release模式下会输出");
                    break;
                  case 4:
                    logE("错误信息，Release模式下会输出 错误信息，Release模式下会输出 错误信息，Release模式下会输出 错误信息，"
                        "Release模式下会输出 错误信息，Release模式下会输出 错误信息，Release模式下会输出 错误信息，Release模式下会输出");
                    break;
                  case 5:
                    logStackV("输出时会打印当前函数调用堆栈");
                    break;
                  case 6:
                    logStackD(["测试list输出", "测试list输出", "测试list输出"]);
                    break;
                  case 7:
                    logStackI({"key1": 1, "key2": "测试map输出"});
                    break;
                  case 8:
                    logStackW(
                        'Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        '============================================================================= '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        '============================================================================= '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        '============================================================================= '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        '============================================================================= '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        '============================================================================= '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        'Info message Info message Info message Info message Info message Info message '
                        '============================================================================= '
                        'Info message Info message Info message Info message Info message ');
                    break;
                  case 9:
                    logStackE(
                        "错误信息，Release模式下会输出", "空指针异常", StackTrace.current);
                    break;
                }
              },
            ),
          ),
        );
      },
      child: const Text('日志打印测试'),
    );
  }

  Widget btnNetworkHtml() {
    return TextButton(
      onPressed: () async {
        Response<String> data = await dio.get(
          // 'https://www.jiemodui.com/N/132803.html',
          'https://sspai.com/post/75079',
          options: Options(
            headers: {
              'User-Agent': 'Mozilla/5.0 (Macintosh; '
                  'Intel Mac OS X 10_15_7) AppleWebKit/537.36'
                  ' (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36',
            },
          ),
        );
        logBoxN(data);
      },
      child: const Text('html获取'),
    );
  }
}
