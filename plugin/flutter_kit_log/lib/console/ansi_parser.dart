import 'package:flutter/material.dart';

enum AnsiType { text, bracket, code }

class AnsiParser {
  final bool dark;

  AnsiParser({this.dark = true});

  Color? foreground;
  Color? background;

  List<TextSpan> parse(String content) {
    var spans = <TextSpan>[];
    var state = AnsiType.text;
    var buffer = StringBuffer();
    var text = StringBuffer();
    var code = 0;
    List<int> codes = [];

    for (var i = 0, n = content.length; i < n; i++) {
      var character = content.substring(i, i + 1);

      switch (state) {
        case AnsiType.text:
          if (character == '\u001b') {
            state = AnsiType.bracket;
            buffer.write(character);
            code = 0;
            codes = [];
          } else {
            text.write(character);
          }
          break;

        case AnsiType.bracket:
          buffer.write(character);
          if (character == '[') {
            state = AnsiType.code;
          } else {
            state = AnsiType.text;
            text.write(buffer);
          }
          break;

        case AnsiType.code:
          buffer.write(character);
          var codeUnit = character.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (character == ';') {
            codes.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans.add(createSpan(text.toString()));
              text.clear();
            }
            state = AnsiType.text;
            if (character == 'm') {
              codes.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }

          break;
      }
    }

    spans.add(createSpan(text.toString()));
    return spans;
  }

  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        foreground = getColor(0, true);
        background = getColor(0, false);
        break;
      case 38:
        foreground = getColor(codes[2], true);
        break;
      case 39:
        foreground = getColor(0, true);
        break;
      case 48:
        background = getColor(codes[2], false);
        break;
      case 49:
        background = getColor(0, false);
    }
  }

  Color? getColor(int colorCode, bool foreground) {
    switch (colorCode) {
      case 12:
        return dark ? Colors.lightBlue[300] : Colors.indigo[700];
      case 208:
        return dark ? Colors.orange[300] : Colors.orange[700];
      case 196:
        return dark ? Colors.red[300] : Colors.red[700];
      case 35:
        return dark ? Colors.pink[300] : Colors.pink[700];
      case 244:
        return dark ? Colors.grey[400] : Colors.grey;
      case 250:
        return dark ? Colors.white : Colors.black;
    }
    return foreground ? Colors.black : Colors.transparent;
  }

  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: foreground,
        backgroundColor: background,
      ),
    );
  }
}
