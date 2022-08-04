import 'dart:ui';

import 'package:flutter_kit_transfer/platform/platform.dart';

class ScreenAdapter {
  ScreenAdapter._();

  static final ScreenAdapter _instance = ScreenAdapter._();

  factory ScreenAdapter() => _instance;

  double scale = 1.0;

  static void init(double width) {
    Size dpSize = window.physicalSize / window.devicePixelRatio;
    if (dpSize == Size.zero) {
      return;
    }
    if (GetPlatform.isWeb || GetPlatform.isDesktop) {
      // 桌面端直接不适配
      width = dpSize.width;
    } else if (dpSize.longestSide > 1000) {
      // 长边的dp大于1000，适配平板，就不能在对组件进行比例缩放
      // 小米10的长边是800多一点
      width = dpSize.width / 1;
    }
    _instance.scale = dpSize.width / width;
  }

  static double setWidth(num width) {
    return width.w;
  }
}

extension ScreenExt on num {
  double get w => ScreenAdapter().scale * this;
}
