import 'html_stub.dart'
    if (dart.library.io) 'html_native.dart'
    if (dart.library.html) 'html_web.dart';

class Html {
  static String get browseHref => HtmlInterface.browseHref;

  static String get protocol => HtmlInterface.protocol;

  static String get apiHost => HtmlInterface.apiHost;
}
