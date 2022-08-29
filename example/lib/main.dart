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
            2,
            (int i) {
              if (i == 0) {
                return dio.get(
                  'http://api.debug.100.com.tw/api/configs?config_type%5B%5D=decoration_stage&config_type%5B%5D=style'
                  // '&config_type%5B%5D=space&config_type%5B%5D=size&config_type%5B%5D=budget&config_type%5B%5D=kind&config_type%5B%5D=room'
                  // '&config_type%5B%5D=hall&config_type%5B%5D=bath&config_type%5B%5D=region&config_type%5B%5D=element&config_type%5B%5D=img_colors'
                  // '&config_type%5B%5D=service_region&config_type%5B%5D=work_show_mode&config_type%5B%5D=show_start_page'
                  '&config_type%5B%5D=show_instruction_page&config_type%5B%5D=show_work_detail_message_form&config_type%5B%5D=ai_service',
                  options: Options(
                    headers: {
                      'User-Agent':
                          'version/5.8.8 version_code/232 clients/Android imei/x095009b-x13d-x82b-x66b-xadf1d0d51d4 model/pixel-3-xl system/12 framework/flutter image/webp',
                      'Accept': 'application/vnd.100design.v2+json; image/webp',
                    },
                  ),
                );
              } else if (i == 1) {
                return dio.get(
                  'http://api.debug.100.com.tw/api/works',
                  options: Options(
                    headers: {
                      'User-Agent':
                          'version/5.8.8 version_code/232 clients/Android imei/x095009b-x13d-x82b-x66b-xadf1d0d51d4 model/pixel-3-xl system/12 framework/flutter image/webp',
                      'Accept': 'application/vnd.100design.v2+json; image/webp',
                    },
                  ),
                );
              }
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
                    logE(
                        "错误信息，Release模式下会输出 错误信息，Release模式下会输出 错误信息，Release模式下会输出 错误信息，"
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
