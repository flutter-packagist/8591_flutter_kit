import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:platform/platform.dart';

import 'icon.dart' as icon;

class DeviceInfoPanel extends StatefulWidget implements Pluggable {
  final Platform platform;

  const DeviceInfoPanel({
    Key? key,
    this.platform = const LocalPlatform(),
  }) : super(key: key);

  @override
  DeviceInfoPanelState createState() => DeviceInfoPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'DeviceInfo';

  @override
  String get displayName => '设备信息';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  bool get keepState => true;
}

class DeviceInfoPanelState extends State<DeviceInfoPanel> {
  var _deviceInfo = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      child: ColoredBox(
        color: Colors.white,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _deviceInfo.keys.length,
          itemBuilder: (ctx, index) => ListTile(
            title: Text(
              _deviceInfo.keys.elementAt(index),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 5 * 3,
              ),
              child: Text(
                '${_deviceInfo.values.elementAt(index)}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> dataMap = {};
    if (widget.platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      dataMap = _readAndroidDeviceInfo(androidDeviceInfo);
    } else if (widget.platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      dataMap = _readIosDeviceInfo(iosDeviceInfo);
    }
    _deviceInfo = dataMap;
    setState(() {});
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.id,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname': data.utsname.sysname,
      'utsname.nodename': data.utsname.nodename,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'utsname.machine': data.utsname.machine,
    };
  }
}
