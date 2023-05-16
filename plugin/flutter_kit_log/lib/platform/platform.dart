import 'platform_web.dart' if (dart.library.io) 'platform_io.dart';

enum DevicePlatform { unknown, web, mobile, desktop }

class GetPlatform {
  static bool get isWeb => GeneralPlatform.isWeb;

  static bool get isMacOS => GeneralPlatform.isMacOS;

  static bool get isWindows => GeneralPlatform.isWindows;

  static bool get isLinux => GeneralPlatform.isLinux;

  static bool get isAndroid => GeneralPlatform.isAndroid;

  static bool get isIOS => GeneralPlatform.isIOS;

  static bool get isFuchsia => GeneralPlatform.isFuchsia;

  static bool get isMobile => GetPlatform.isIOS || GetPlatform.isAndroid;

  static bool get isDesktop =>
      GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux;

  static DevicePlatform get type {
    if (isWeb) {
      return DevicePlatform.web;
    } else if (isAndroid || isIOS) {
      return DevicePlatform.mobile;
    } else if (isDesktop) {
      return DevicePlatform.desktop;
    }
    return DevicePlatform.unknown;
  }
}
