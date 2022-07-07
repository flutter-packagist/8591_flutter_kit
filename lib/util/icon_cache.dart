import 'package:flutter/widgets.dart';
import 'package:flutter_kit/core/pluggable.dart';

class IconCache {
  static final Map<String, Widget> _icons = {};

  static Widget? icon(Pluggable pluggableInfo) {
    if (!_icons.containsKey(pluggableInfo.name)) {
      final image = Image(image: pluggableInfo.iconImageProvider);
      _icons.putIfAbsent(pluggableInfo.name, () => image);
    }
    return _icons[pluggableInfo.name];
  }
}
