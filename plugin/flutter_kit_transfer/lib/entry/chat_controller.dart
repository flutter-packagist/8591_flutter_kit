import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:flutter_kit_transfer/utils/scroll_util.dart';
import 'package:get/get.dart' hide GetPlatform, Response;
import 'package:path/path.dart' hide context;
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../config/config.dart';
import '../model/base_message.dart';
import '../model/custom_message.dart';
import '../model/message_factory.dart';
import '../platform/platform.dart';
import '../service/chat_server.dart';
import '../service/device_manager.dart';
import '../service/file_server.dart';
import '../service/init_server.dart';
import '../utils/dialog_util.dart';
import '../utils/dio_util.dart';
import '../utils/file_util.dart';
import '../utils/log_util.dart';
import '../utils/print_util.dart';
import '../utils/socket_util.dart';
import '../utils/toast_util.dart';
import '../utils/unique_util.dart';
import '../widget/bubble_dialog.dart';
import '../widget/qrcode_dialog.dart';
import 'chat_model.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  ChatModel model = ChatModel();

  late BuildContext context;
  late TickerProvider vsync;

  /// 侧边栏菜单动画
  late AnimationController navAnimationController;
  late Animation navAnimationOffset;

  /// 输入框菜单动画
  late AnimationController menuAnimationController;

  /// 聊天列表滑动控制器
  final ScrollController scrollController = ScrollController();

  /// 输入框控制器
  final TextEditingController textEditingController = TextEditingController();

  /// 输入框焦点
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    initTextFieldListener();
    initChatView();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    navAnimationController.dispose();
    menuAnimationController.dispose();
    InitServer().stopSendBroadcast();
    ChatServer().stop();
    FileServer().stop();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshLocalAddress();
      initChatList();
    }
  }
}

extension Private on ChatController {
  void initTextFieldListener() {
    focusNode.onKey = (FocusNode node, event) {
      model.inputMultiline = event.isShiftPressed;
      update();
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        return KeyEventResult.skipRemainingHandlers;
      }
      return KeyEventResult.ignored;
    };
  }

  void initChatView() {
    if (!GetPlatform.isWeb) {
      createChatRoom();
    } else {
      initChatList();
    }
  }
}

extension SetData on ChatController {
  /// 创建聊天房间
  Future<void> createChatRoom() async {
    // 启动消息服务器
    model.messageBindPort = await ChatServer().start(
      receiveMessage: (request, headers) async {
        headers[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
        Map<String, dynamic> data = jsonDecode(await request.readAsString());
        receiveMessage(data);
        return shelf.Response.ok('success', headers: headers);
      },
      readMessage: (request, headers) {
        // logD("readMessage: ${model.messageQueue.length}");
        if (model.messageQueue.isNotEmpty) {
          return shelf.Response.ok(
            jsonEncode(model.messageQueue.removeAt(0)),
            headers: headers,
          );
        }
        return shelf.Response.ok('{}', headers: headers);
      },
    );
    logD('消息服务器端口 : ${model.messageBindPort}');

    StringBuffer udpData = StringBuffer();
    udpData.write(await UniqueUtil.getDeviceId());
    udpData.write(',${model.messageBindPort}');
    // 将设备ID与聊天服务器成功创建的端口UDP广播出去
    InitServer().startSendBroadcast(udpData.toString());
    // 保存本地的IP地址列表
    if (!GetPlatform.isWeb) {
      await refreshLocalAddress();
      update();
    }
    initChatList();
  }

  /// 服务器接收到消息，进行处理并加入缓存
  void receiveMessage(Map<String, dynamic> data) {
    model.messageCache.add(data);
    if (data['msgType'] == 'exit') {
      DeviceManager().onClose(data['deviceId']);
      update();
      return;
    }
    BaseMessage baseMessage = MessageFactory.fromJson(data);
    dispatchMessage(baseMessage, chatWidgetList);
  }

  /// 对不同类型的消息进行处理
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

          sendJoinEvent('$url:${message.messagePort}');
          update();
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
      update();
    }
  }

  /// 初始化聊天列表
  Future<void> initChatList() async {
    // 清除聊天消息列表
    // chatWidgetList.clear();
    // 设置连接状态
    model.connectState = true;

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

  /// Web端加入聊天室
  void joinChatRoomWeb() {
    String url = "";
    if (!kReleaseMode) {
      url = "http://192.168.3.18:12000/";
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
    update();

    Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      String webUrl = '${url}message';
      Response response = await httpInstance.get(webUrl);
      try {
        Map<String, dynamic> data = jsonDecode(response.data);
        BaseMessage message = MessageFactory.fromJson(data);
        dispatchMessage(message, chatWidgetList);
      } catch (e) {
        logE("解析消息失败: ${response.data}");
      }
    });
  }
}

extension GetData on ChatController {
  /// 根据屏幕判断是否为移动设备
  bool get isMobile => ResponsiveBreakpoints.of(context).isMobile;

  /// 判断屏幕是否有拖拽动作
  bool get isDragging => model.dragging;

  /// 当前连接状态
  bool get connectState => model.connectState;

  /// 设备图标
  String deviceIcon(DevicePlatform platform) {
    switch (platform) {
      case DevicePlatform.mobile:
        return 'assets/icon/phone.png';
      case DevicePlatform.desktop:
        return 'assets/icon/computer.png';
      case DevicePlatform.web:
        return 'assets/icon/browser.png';
      default:
        return 'assets/icon/all.png';
    }
  }

  /// 列表渲染的widget列表
  List<Widget> get chatWidgetList => model.chatWidgetList;

  /// 是否有消息输入
  bool get hasInput => textEditingController.text.isNotEmpty;
}

extension Action on ChatController {
  void onDragEntered(DropEventDetails details) {
    model.dragging = true;
    update();
  }

  void onDragExited(DropEventDetails details) {
    model.dragging = false;
    update();
  }

  void onDragDone(DropDoneDetails details) {
    logD('files -> ${details.files}');
    if (details.files.isNotEmpty) {
      // sendXFiles(details.files); todo
    }
  }

  void onQrcodeIconTap() {
    showAnimationDialog(
      context,
      child: QrcodeDialog(
        hostList: model.addressList,
        port: model.messageBindPort,
      ),
    );
  }

  void onMoreIconTap() {
    showAnimationDialog(
      context,
      barrierColor: Colors.transparent,
      transitionType: PageTransitionType.menu,
      child: BubbleDialog(sendJoinEvent: sendJoinEvent),
    );
  }

  void onLeftNavIconTap(int index) {
    navAnimationOffset = Tween<double>(
      begin: navAnimationOffset.value,
      end: index * 60.w,
    ).animate(navAnimationController);
    navAnimationController.reset();
    navAnimationController.forward();
  }

  void onTextFieldChanged(String text) {
    update();
  }

  void onTextFieldSubmitted(String text) {
    if (model.inputMultiline) {
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
  }

  void onSubmitIconTap() {
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
}

extension Network on ChatController {
  void sendJoinEvent(String url) {
    ChatServer().sendJoinEvent(
      url,
      model.addressList,
      model.shelfBindPort,
      model.messageBindPort,
    );
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
    scrollController.scrollToEnd();
    update();
  }

  /// 将消息加入到消息队列中，并post发送到 /message 接口
  void sendMessage(BaseMessage message) {
    message.platform = GetPlatform.type.index;
    message.deviceId = InitServer().deviceId;
    logD("sendMessage: $message");
    model.messageQueue.add(message.toJson());
    logD("messageQueue: ${model.messageQueue.length}");
    DeviceManager().sendData(message.toJson());
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
    FileServer().deployFile(path, model.shelfBindPort);
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
      address: model.addressList,
      port: model.shelfBindPort,
      fromDevice: InitServer().deviceName,
    );
    logD("文件信息: ${prettyJsonMap(fileMessage.toJson())}");
    sendMessage(fileMessage);
    Widget? messageItem = MessageFactory.getMessageItem(fileMessage, true);
    if (messageItem != null) chatWidgetList.add(messageItem);
    scrollController.scrollToEnd();
    update();
  }

  /// 获取绑定的端口
  Future<void> getSuccessBindPort() async {
    if (!GetPlatform.isWeb) {
      model.shelfBindPort = await getSafePort(
        Config.shelfPortRangeStart,
        Config.shelfPortRangeEnd,
      );
      FileServer().checkToken(model.shelfBindPort);
      model.fileServerPort = await getSafePort(
        Config.filePortRangeStart,
        Config.filePortRangeEnd,
      );
      FileServer().start(model.fileServerPort);
      logD('shelf will server with ${model.shelfBindPort} port');
      logD('file server started with ${model.fileServerPort} port');
    }
  }

  /// 刷新本地ip地址列表
  Future<void> refreshLocalAddress() async {
    model.addressList = await localAddress();
    logD("本地地址列表：${model.addressList}");
  }
}
