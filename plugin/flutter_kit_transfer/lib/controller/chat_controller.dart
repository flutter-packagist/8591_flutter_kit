import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:flutter_kit_transfer/service/init_server.dart';
import 'package:flutter_kit_transfer/utils/print_util.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:flutter_kit_transfer/utils/toast_util.dart';
import 'package:flutter_kit_transfer/widget/qrcode_dialog.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../config/config.dart';
import '../model/base_message.dart';
import '../model/custom_message.dart';
import '../model/message_factory.dart';
import '../platform/platform.dart';
import '../service/chat_server.dart';
import '../service/device_manager.dart';
import '../service/file_server.dart';
import '../utils/dio_util.dart';
import '../utils/file_util.dart';
import '../utils/scroll_util.dart';
import '../utils/socket_util.dart';
import '../utils/unique_util.dart';
import '../widget/bubble_dialog.dart';

class ChatNotifier extends ChangeNotifier with WidgetsBindingObserver {
  // 当前连接状态
  ValueNotifier<bool> connectState = ValueNotifier(false);

  // 列表渲染的widget列表
  List<Widget> chatWidgetList = [];

  // 本机的ip地址列表
  List<String> addressList = [];

  // 消息服务器成功绑定的端口
  int messageBindPort = -1;

  // 文件服务器成功绑定的端口
  int shelfBindPort = -1;
  int fileServerPort = -1;

  // 列表滑动控制器
  ScrollController scrollController = ScrollController();

  // 当前是否有拖拽动作
  bool dropping = false;

  // 侧边栏菜单动画
  late AnimationController animationController;
  late Animation animationOffset;
  int leftNavIndex = 0;

  // 输入框相关状态
  bool inputMultiline = false;
  bool hasInput = false;

  // 输入框焦点
  FocusNode focusNode = FocusNode();

  // 输入框控制器
  TextEditingController textEditingController = TextEditingController();

  // 消息队列，发送的消息会存到这个队列中，连接服务的客户端从队列中轮询取消息
  List<Map<String, dynamic>> messageQueue = [];

  // 消息缓存，缓存开启服务的设备与客户端的所有交互的消息
  List<Map<String, dynamic>> messageCache = [];

  // 输入框菜单动画
  late AnimationController menuAnimationController;

  void initNotifier() {
    WidgetsBinding.instance.addObserver(this);
    initListener();
    if (!GetPlatform.isWeb) {
      createChatRoom();
    } else {
      initChatList();
    }
  }

  void initListener() {
    hasInput = textEditingController.text.isNotEmpty;
    focusNode.onKey = (FocusNode node, event) {
      inputMultiline = event.isShiftPressed;
      notifyListeners();
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        return KeyEventResult.skipRemainingHandlers;
      }
      return KeyEventResult.ignored;
    };
  }

  // 刷新本地ip地址列表
  Future<void> refreshLocalAddress() async {
    addressList = await localAddress();
    logI("本地地址列表：$addressList");
  }

  // 创建聊天房间
  Future<void> createChatRoom() async {
    // 启动消息服务器
    messageBindPort = await ChatServer().start(
      receiveMessage: (request, headers) async {
        headers[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
        Map<String, dynamic> data = jsonDecode(await request.readAsString());
        receiveMessage(data);
        return shelf.Response.ok('success', headers: headers);
      },
      readMessage: (request, headers) {
        if (messageQueue.isNotEmpty) {
          return shelf.Response.ok(
            jsonEncode(messageQueue.removeAt(0)),
            headers: headers,
          );
        }
        return shelf.Response.ok('{}', headers: headers);
      },
    );
    logI('消息服务器端口 : $messageBindPort');

    StringBuffer udpData = StringBuffer();
    udpData.write(await UniqueUtil.getDeviceId());
    udpData.write(',$messageBindPort');
    // 将设备ID与聊天服务器成功创建的端口UDP广播出去
    InitServer().startSendBroadcast(udpData.toString());
    // 保存本地的IP地址列表
    if (!GetPlatform.isWeb) {
      await refreshLocalAddress();
      notifyListeners();
    }
    initChatList();
  }

  // 服务器接收到消息，进行处理并加入缓存
  void receiveMessage(Map<String, dynamic> data) {
    messageQueue.add(data);
    if (data['msgType'] == 'exit') {
      DeviceManager().onClose(data['deviceId']);
      notifyListeners();
      return;
    }
    BaseMessage baseMessage = MessageFactory.fromJson(data);
    dispatchMessage(baseMessage, chatWidgetList);
  }

  // 初始化聊天列表
  Future<void> initChatList() async {
    // 清除聊天消息列表
    // chatWidgetList.clear();
    // 设置连接状态
    connectState.value = true;

    if (GetPlatform.isWeb) {
      joinChatRoomWeb();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
    await getSuccessBindPort();
    if (!InitServer().initLock.isCompleted) {
      InitServer().initLock.complete("初始化完毕");
    }
  }

  // Web端加入聊天室
  void joinChatRoomWeb() {
    String url = "";
    if (!kReleaseMode) {
      url = "http://localhost:12000/";
    }
    Uri uri = Uri.parse(url);
    DeviceManager().onConnect(
      id: InitServer().deviceId,
      name: InitServer().deviceName,
      platform: DevicePlatform.web,
      uri: uri.host.isEmpty ? '' : '${uri.scheme}://${uri.host}',
      port: uri.port,
    );

    sendJoinEvent(url);
    notifyListeners();

    Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      String webUrl = '${url}message';
      Response response = await httpInstance.get(webUrl);
      try {
        Map<String, dynamic> data = jsonDecode(response.data);
        BaseMessage message = MessageFactory.fromJson(data);
        dispatchMessage(message, chatWidgetList);
      } catch (e) {
        logStackE("解析消息失败: ${response.data}", e, StackTrace.current);
      }
    });
  }

  // 对不同类型的消息进行处理
  Future<void> dispatchMessage(BaseMessage message, List<Widget> child) async {
    if (message is JoinMessage) {
      if (!GetPlatform.isWeb) {
        // 当连接设备不是本机的时处理
        if (message.deviceId != await UniqueUtil.getDeviceId()) {
          String url = await getUrlByAddressAndPort(
            message.address,
            message.filePort,
          );
          // 查看链接是否已经被记录
          try {
            DeviceManager().connectedDevice.firstWhere(
                  (element) => element.id == message.deviceId,
                );
          } catch (e) {
            DeviceManager().onConnect(
              id: message.deviceId,
              name: message.deviceName,
              platform: DevicePlatform.values[message.platform],
              uri: url,
              port: message.messagePort,
            );
          }

          // sendJoinEvent('$url:${message.messagePort}');
          notifyListeners();
          return;
        }
      }
    } else if (message is NotifyMessage) {
      if (GetPlatform.isWeb) {}
    } else if (message is FileMessage) {
      String url = await getUrlByAddressAndPort(
        message.address,
        message.port,
      );
      message.url = '$url:${message.port}';
    }

    // 往聊天列表中添加一条消息
    Widget? itemWidget = MessageFactory.getMessageItem(message, false);
    if (itemWidget != null && message.deviceId != InitServer().deviceId) {
      chatWidgetList.add(itemWidget);
      scrollController.scrollToEnd();
      notifyListeners();
    }
  }

  /// 获取绑定的端口
  Future<void> getSuccessBindPort() async {
    if (!GetPlatform.isWeb) {
      shelfBindPort = await getSafePort(
        Config.shelfPortRangeStart,
        Config.shelfPortRangeEnd,
      );
      FileServer().checkToken(shelfBindPort);
      fileServerPort = await getSafePort(
        Config.filePortRangeStart,
        Config.filePortRangeEnd,
      );
      FileServer().start(fileServerPort);
      logI('shelf will server with $shelfBindPort port');
      logI('file server started with $fileServerPort port');
    }
  }

  void onDragEntered(DropEventDetails details) {
    dropping = true;
    notifyListeners();
  }

  void onDragExited(DropEventDetails details) {
    dropping = false;
    notifyListeners();
  }

  void onDragDone(DropDoneDetails details) {
    notifyListeners();
    logD('files -> ${details.files}');
    notifyListeners();
    if (details.files.isNotEmpty) {
      // sendXFiles(details.files); todo
    }
  }

  void onLeftNavIconTap(int index) {
    animationOffset =
        Tween<double>(begin: animationOffset.value, end: index * 60.w)
            .animate(animationController);
    animationController.reset();
    animationController.forward();
  }

  void sendJoinEvent(String url) {
    ChatServer().sendJoinEvent(
      url,
      addressList,
      shelfBindPort,
      messageBindPort,
    );
  }

  // 将消息加入到消息队列中，并post发送到 /message 接口
  void sendMessage(BaseMessage message) {
    message.platform = GetPlatform.type.index;
    message.deviceId = InitServer().deviceId;
    messageQueue.add(message.toJson());
    DeviceManager().sendData(message.toJson());
  }

  void sendTextMsg() {
    if (textEditingController.text.isEmpty) {
      showToast("发送内容不能为空");
      return;
    }
    TextMessage textMessage = TextMessage(
      content: textEditingController.text,
      fromDevice: InitServer().deviceName,
    );
    sendMessage(textMessage);
    Widget? messageItem = MessageFactory.getMessageItem(textMessage, true);
    if (messageItem != null) chatWidgetList.add(messageItem);
    textEditingController.clear();
    hasInput = textEditingController.text.isNotEmpty;
    notifyListeners();
    scrollController.scrollToEnd();
  }

  Future<void> sendFileByBrowser() async {}

  Future<void> sendFileByClient() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowCompression: false, allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();
      for (var file in files) {
        sendFileWithPath(file.path);
      }
    } else {
      // User canceled the picker
    }
  }

  Future<void> sendFileWithPath(String path) async {
    await getSuccessBindPort();
    FileServer().deployFile(path, shelfBindPort);
    // 替换windows的路径分隔符
    path = path.replaceAll('\\', '/');
    // 读取文件大小
    int size = await File(path).length();
    // 替换windows盘符
    path = path.replaceAll(RegExp('^[A-Z]:'), '');
    // 定义文件消息
    Context pathContext = GetPlatform.isWindows ? windows : posix;
    final FileMessage fileMessage = FileMessage(
      filePath: path,
      fileName: pathContext.basename(path),
      fileSize: FileUtil.getFileSize(size) ?? "",
      address: addressList,
      port: shelfBindPort,
      fromDevice: InitServer().deviceName,
    );
    logI("文件信息: ${prettyJsonMap(fileMessage.toJson())}");
    sendMessage(fileMessage);
    Widget? messageItem = MessageFactory.getMessageItem(fileMessage, true);
    if (messageItem != null) chatWidgetList.add(messageItem);
    notifyListeners();
    scrollController.scrollToEnd();
  }

  void onEditTextSubmit(String text) {
    if (inputMultiline) {
      textEditingController.value = TextEditingValue(
        text: '${textEditingController.text}\n',
        selection: TextSelection.collapsed(
          offset: textEditingController.selection.end + 1,
        ),
      );
      focusNode.requestFocus();
      return;
    }
    sendTextMsg();
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  void onEditTextChanged(String text) {
    // 这个监听主要是为了改变发送按钮为+号按钮
    hasInput = text.isNotEmpty;
    notifyListeners();
  }

  void onEditBoxIconTap() {
    if (hasInput) {
      sendTextMsg();
    } else {
      if (menuAnimationController.isCompleted) {
        menuAnimationController.reverse();
      } else {
        menuAnimationController.forward();
      }
    }
  }

  void onMenuChooserSystemFileManager() {
    menuAnimationController.reverse();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (GetPlatform.isWeb) {
        sendFileByBrowser();
      } else {
        sendFileByClient();
      }
    });
  }

  void onMenuChooserCustomFileManager() {
    menuAnimationController.reverse();
    Future.delayed(const Duration(milliseconds: 100), () {
      // todo
    });
  }

  void onMenuChooserFolder() {
    menuAnimationController.reverse();
    Future.delayed(const Duration(milliseconds: 100), () {
      // todo
    });
  }

  void onQrcodeIconTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return QrcodeDialog(hostList: addressList, port: messageBindPort);
      },
    );
  }

  void onMoreIconTap(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeIn.transform(a1.value);
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 20, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40.w,
                right: 10.w,
              ),
              child: Material(
                color: Colors.transparent,
                child: BubbleDialog(sendJoinEvent: sendJoinEvent),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return const Center();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        refreshLocalAddress();
        initChatList();
        break;
      default:
    }
  }

  void disposeNotifier() {
    WidgetsBinding.instance.removeObserver(this);
    animationController.dispose();
    menuAnimationController.dispose();
  }
}
