import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/core/plugin_manager.dart';
import 'package:flutter_kit/widget/root_widget.dart';
import 'package:flutter_kit_code/widget/code_display_panel.dart';
import 'package:flutter_kit_device/cpu_info/cpu_info_panel.dart';
import 'package:flutter_kit_device/device_info/device_info_panel.dart';
import 'package:flutter_kit_dio/core/pluggable.dart';

final Dio dio = Dio()..options = BaseOptions(connectTimeout: 10000);

void main() {
  PluginManager().registerAll([
    const CpuInfoPanel(),
    const DeviceInfoPanel(),
    const CodeDisplayPanel(),
    DioInspector(dio: dio),
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
            TextButton(
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
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
