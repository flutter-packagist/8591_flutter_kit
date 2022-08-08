import 'package:device_info_plus/device_info_plus.dart';

import '../platform/platform.dart';

/// 获取本机的设备名称
class UniqueUtil {
  UniqueUtil._();

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getDeviceName() async {
    if (GetPlatform.isWeb) {
      var deviceInfo = await deviceInfoPlugin.webBrowserInfo;
      return "${deviceInfo.browserName.name}-${deviceInfo.platform.toString()}";
    } else if (GetPlatform.isWindows) {
      var deviceInfo = await deviceInfoPlugin.windowsInfo;
      return deviceInfo.computerName;
    } else if (GetPlatform.isLinux) {
      var deviceInfo = await deviceInfoPlugin.linuxInfo;
      return deviceInfo.prettyName;
    } else if (GetPlatform.isMacOS) {
      var deviceInfo = await deviceInfoPlugin.macOsInfo;
      return deviceInfo.computerName;
    } else if (GetPlatform.isAndroid) {
      var deviceInfo = await deviceInfoPlugin.androidInfo;
      return deviceInfo.model ?? "";
    } else if (GetPlatform.isIOS) {
      var deviceInfo = await deviceInfoPlugin.iosInfo;
      return deviceInfo.name ?? "";
    }
    return 'unknown';
  }

  static Future<String> getDeviceId() async {
    String deviceId = await getDeviceName();
    return deviceId.hashCode.toString();
  }
}
