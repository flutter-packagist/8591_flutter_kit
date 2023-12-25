import 'package:example/app_config.dart';
import 'package:flutter_kit_transfer/service/init_server.dart';

class AppService {
  AppService._();

  static AppService? _instance;

  factory AppService() {
    _instance ??= AppService._();
    return _instance!;
  }

  Future<void> init() async {
    await InitServer().init(packageName: AppConfig.packageName);
  }

  Future<void> initLazy() async {
    await InitServer().initLazy();
  }
}
