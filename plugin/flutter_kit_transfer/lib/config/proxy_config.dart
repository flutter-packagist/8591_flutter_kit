import 'package:log_wrapper/log/log.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

//前端页面访问本地域名
const String localHost = 'localhost';

//前端页面访问本地端口号
const int localPort = 12000;

//目标域名
const String targetUrl = 'http://192.168.3.6:12000';

Future main() async {
  var server = await shelf_io.serve(
    proxyHandler(targetUrl),
    localHost,
    localPort,
  );
  // 添加上跨域的这几个header
  server.defaultResponseHeaders.add('Access-Control-Allow-Origin', '*');
  server.defaultResponseHeaders.add('Access-Control-Allow-Credentials', true);
  logD('Serving at http://${server.address.host}:${server.port}');
}
