import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:flutter_kit/widget/menu_page.dart';

import 'icon.dart' as icon;

class SettingPanel extends StatefulWidget implements Pluggable {
  const SettingPanel({Key? key}) : super(key: key);

  @override
  SettingPanelState createState() => SettingPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'settings';

  @override
  String get displayName => '设置';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  bool get keepState => true;
}

class SettingPanelState extends State<SettingPanel> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      home: ConsolePanel(
        child: ColoredBox(
          color: Colors.white,
          child: listView,
        ),
      ),
    );
  }

  Widget get listView {
    return ListView(children: [
      const IconTextButton(
        onPressed: AppSettings.openAppSettings,
        title: "APP设置",
        icon: Icons.apps,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.device),
        title: "关于手机",
        icon: Icons.perm_device_info,
        content: "Android手机：快速点击当前系统版本号（不是Android版本）5次进入开发者模式",
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.developer),
        title: "开发者选项",
        content: "Android手机：如果开发者选项未开启，请先前往\"关于手机\"选项中开启",
        icon: Icons.developer_mode,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.notification),
        title: "通知栏管理",
        icon: Icons.notifications,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.sound),
        title: "声音设置",
        icon: Icons.volume_up,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.display),
        title: "屏幕调整",
        icon: Icons.display_settings,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.wifi),
        title: "WIFI设置",
        icon: Icons.wifi,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.location),
        title: "GPS设置",
        icon: Icons.location_on,
      ),
      IconTextButton(
        onPressed: () =>
            AppSettings.openAppSettings(type: AppSettingsType.security),
        title: "安全性",
        icon: Icons.security,
      ),
    ]);
  }
}

class IconTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String content;
  final IconData icon;

  const IconTextButton({
    Key? key,
    this.onPressed,
    required this.title,
    required this.icon,
    this.content = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Icon(icon, color: Colors.black),
      ),
      label: Text.rich(TextSpan(children: [
        TextSpan(
          text: title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            height: 1.1,
          ),
        ),
        TextSpan(
          text: content.isEmpty ? "" : "\n$content",
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ])),
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        shadowColor: MaterialStateProperty.all(Colors.grey),
        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        )),
      ),
    );
  }
}
