import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';

import '../service/init_server.dart';
import 'icon.dart' as icon;
import 'responsive_entry.dart';

class TransferPanel extends StatelessWidget implements Pluggable {
  final String packageName;

  const TransferPanel({Key? key, required this.packageName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      home: const ResponsiveEntry(),
    );
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'File transfer';

  @override
  String get displayName => '文件传输';

  @override
  void onTrigger() async {
    await InitServer().init(packageName: packageName);
    await InitServer().initLazy();
  }
}
