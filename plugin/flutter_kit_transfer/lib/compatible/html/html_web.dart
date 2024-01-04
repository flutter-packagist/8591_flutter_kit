// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class HtmlInterface {
  static String get browseHref => window.location.href;

  static String get protocol => window.location.protocol;

  static String get apiHost => window.location.host;
}
