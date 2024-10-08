import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_transfer/flutter_kit_transfer.dart';
import 'package:log_wrapper/log/log.dart';

import 'app_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppService().init();
    runApp(const MyApp());
    setupSystemChrome();
    AppService().initLazy();
  }, (Object error, StackTrace stack) {
    logStackE("$error", error, stack);
  });
}

void setupSystemChrome() {
  if (GetPlatform.isWeb) return;
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
      title: '文件传输',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ResponsiveEntry(),
    );
  }
}
