class Config {
  Config._();

  // 下面两个端口是单个文件部署用到的端口
  static int shelfPortRangeStart = 13000;
  static int shelfPortRangeEnd = 13010;

  // 下面两个端口是文件服务器用到的端口，主要用来web上传文件到客户端
  static int filePortRangeStart = 13010;
  static int filePortRangeEnd = 13020;

  // 下面两个是聊天服务器的端口
  static int chatPortRangeStart = 12000;
  static int chatPortRangeEnd = 12010;

  // flutter package名，因为这个会影响assets的路径
  static String flutterPackage = 'flutter_kit_transfer';

  // 本地调试用的ip
  static String localDebugIp = 'http://192.168.13.5:12000/';
}
