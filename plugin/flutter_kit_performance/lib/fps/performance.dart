import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';

import '../fps/icon.dart' as icon;

class Performance extends StatelessWidget implements Pluggable {
  const Performance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: PerformanceOverlay.allEnabled(),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'PerformanceOverlay';

  @override
  String get displayName => 'FPS指标';

  @override
  void onTrigger() {}

  @override
  bool get keepState => false;
}
