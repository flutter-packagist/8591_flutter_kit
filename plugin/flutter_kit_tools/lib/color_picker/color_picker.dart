import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'eye/eye_dropper_layer.dart';
import 'eye/eye_dropper_util.dart';
import 'icon.dart' as icon;

class ColorPicker extends StatefulWidget implements PluggableWithNestedWidget {
  const ColorPicker({Key? key}) : super(key: key);

  @override
  ColorPickerState createState() => ColorPickerState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'ColorPicker';

  @override
  String get displayName => '颜色提取';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  Widget buildNestedWidget(Widget child) {
    return EyeDrop(child: child);
  }

  @override
  bool get keepState => false;
}

class ColorPickerState extends State<ColorPicker> {
  final colorTextStyle = const TextStyle(
    fontFamily: "Monospace",
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  Color? _color = Colors.white;
  bool _panelDown = true;
  int colorState = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (downEvent) {
        if (interceptEvent(downEvent)) return;
        EyeDrop.of(context).capture(context, (color) {
          setState(() => _color = color);
        });
      },
      onPointerMove: (moveEvent) {
        if (interceptEvent(moveEvent)) return;
        double screenHeight = MediaQuery.of(context).size.height;
        if (moveEvent.position.dy < screenHeight * 0.2) {
          _panelDown = true;
        } else if (moveEvent.position.dy > screenHeight * 0.8) {
          _panelDown = false;
        }
        setState(() {});
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: Align(
          alignment: _panelDown ? Alignment.bottomCenter : Alignment.topCenter,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: const [
                  BoxShadow(color: Colors.black54, blurRadius: 12),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  debugPrint(_color?.hexARGB.toString());
                  String? copyData = "";
                  if (colorState == 0) {
                    copyData = _color?.hexARGB.toString();
                  } else if (colorState == 1) {
                    copyData = "${_color?.alpha} ${_color?.red} "
                        "${_color?.green} ${_color?.blue}";
                  } else {
                    copyData =
                        "${((_color?.alpha ?? 0) / 255 * 100).toStringAsFixed(0)}% "
                        "${((_color?.red ?? 0) / 255 * 100).toStringAsFixed(0)}%"
                        "${((_color?.green ?? 0) / 255 * 100).toStringAsFixed(0)}%"
                        "${((_color?.blue ?? 0) / 255 * 100).toStringAsFixed(0)}%";
                  }
                  Clipboard.setData(ClipboardData(text: copyData));
                  Fluttertoast.showToast(msg: "复制成功");
                },
                onDoubleTap: () {
                  if (colorState >= 2) {
                    colorState = 0;
                  } else {
                    colorState++;
                  }
                  setState(() {});
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "A: ",
                        style: colorTextStyle.copyWith(color: Colors.grey),
                      ),
                      TextSpan(
                        text: grey,
                        style: colorTextStyle.copyWith(color: Colors.grey),
                      ),
                      TextSpan(
                        text: "\nR: ",
                        style: colorTextStyle.copyWith(color: Colors.red),
                      ),
                      TextSpan(
                        text: red,
                        style: colorTextStyle.copyWith(color: Colors.red),
                      ),
                      TextSpan(
                        text: "\nG: ",
                        style: colorTextStyle.copyWith(color: Colors.green),
                      ),
                      TextSpan(
                        text: green,
                        style: colorTextStyle.copyWith(color: Colors.green),
                      ),
                      TextSpan(
                        text: "\nB: ",
                        style: colorTextStyle.copyWith(color: Colors.blue),
                      ),
                      TextSpan(
                        text: blue,
                        style: colorTextStyle.copyWith(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool interceptEvent(PointerEvent event) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double safeTop = MediaQuery.of(context).padding.top;
    double safeBottom = MediaQuery.of(context).padding.bottom;
    double heightTop = safeTop + 20;
    double heightBottom = screenHeight - safeBottom - 20;
    if (event.position.dx > screenWidth / 2 - 50 &&
        event.position.dx < screenWidth / 2 + 50) {
      if (!_panelDown &&
          event.position.dy > heightTop &&
          event.position.dy < heightTop + 120) {
        return true;
      }
      if (_panelDown &&
          event.position.dy > heightBottom - 120 &&
          event.position.dy < heightBottom) {
        return true;
      }
    }
    return false;
  }

  String? get grey {
    if (colorState == 0) {
      return _color?.hexARGB.toString().substring(0, 2);
    } else if (colorState == 1) {
      return _color?.alpha.toString();
    } else {
      return "${((_color?.alpha ?? 0) / 255 * 100).toStringAsFixed(0)}%";
    }
  }

  String? get red {
    if (colorState == 0) {
      return _color?.hexARGB.toString().substring(2, 4);
    } else if (colorState == 1) {
      return _color?.red.toString();
    } else {
      return "${((_color?.red ?? 0) / 255 * 100).toStringAsFixed(0)}%";
    }
  }

  String? get green {
    if (colorState == 0) {
      return _color?.hexARGB.toString().substring(4, 6);
    } else if (colorState == 1) {
      return _color?.green.toString();
    } else {
      return "${((_color?.green ?? 0) / 255 * 100).toStringAsFixed(0)}%";
    }
  }

  String? get blue {
    if (colorState == 0) {
      return _color?.hexARGB.toString().substring(6, 8);
    } else if (colorState == 1) {
      return _color?.blue.toString();
    } else {
      return "${((_color?.blue ?? 0) / 255 * 100).toStringAsFixed(0)}%";
    }
  }
}
