import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_log/log/log.dart';
import 'package:flutter_kit_transfer/platform/platform.dart';
import 'package:flutter_kit_transfer/widget/responsive_entry.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ResponsiveEntry(),
    );
  }
}
