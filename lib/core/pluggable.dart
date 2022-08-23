import 'package:flutter/widgets.dart';

abstract class Pluggable {
  String get name;

  String get displayName;

  void onTrigger();

  Widget? buildWidget(BuildContext? context);

  ImageProvider get iconImageProvider;

  bool get keepState;
}

typedef StreamFilter = bool Function(dynamic);

abstract class PluggableWithStream extends Pluggable {
  Stream get stream;

  StreamFilter get streamFilter;
}

abstract class PluggableWithNestedWidget extends Pluggable {
  Widget buildNestedWidget(Widget child);
}

abstract class PluggableWithAnywhereDoor extends Pluggable {
  NavigatorState? get navigator;

  Route? get route;

  String? get routeName;

  Map<String, dynamic>? get routeArgs;

  void popResultReceive(dynamic result);
}
