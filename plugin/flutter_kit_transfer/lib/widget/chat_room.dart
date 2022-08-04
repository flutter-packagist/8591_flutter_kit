import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_log/flutter_kit_log.dart';
import 'package:flutter_kit_transfer/service/init_server.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:flutter_kit_transfer/utils/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
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
import '../utils/scroll_util.dart';
import '../utils/socket_util.dart';
import '../utils/unique_util.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  final ChatNotifier chatNotifier = ChatNotifier();
  bool isMobile = true;

  @override
  void initState() {
    super.initState();
    chatNotifier.initNotifier();

    chatNotifier.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    chatNotifier.animationOffset = Tween<double>(begin: 0, end: 0)
        .animate(chatNotifier.animationController);

    chatNotifier.menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    isMobile = ResponsiveWrapper.of(context).isMobile;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: ChangeNotifierProvider.value(
        value: chatNotifier,
        child: Consumer<ChatNotifier>(
          builder: (context, controller, _) {
            return dropWindow;
          },
        ),
      ),
    );
  }

  Widget get dropWindow {
    return DropTarget(
      onDragEntered: chatNotifier.onDragEntered,
      onDragExited: chatNotifier.onDragExited,
      onDragDone: chatNotifier.onDragDone,
      child: Stack(
        children: [
          body,
          if (chatNotifier.dropping)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Material(
                child: Center(
                  child: Text(
                    '释放以分享文件到共享窗口~',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.w,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget get body {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        left: false,
        child: Column(children: [
          appbar,
          Expanded(
            child: Row(children: [leftNav, chatBody]),
          ),
        ]),
      ),
    );
  }

  Widget get appbar {
    if (!isMobile) return SizedBox(height: 10.w);
    return SizedBox(
      height: 48.w,
      child: Row(children: [
        SizedBox(width: 12.w),
        Text(
          '全部设备',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4.w),
        ValueListenableBuilder<bool>(
          valueListenable: chatNotifier.connectState,
          builder: (_, value, __) {
            return Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: value ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(16.w),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget get leftNav {
    if (!isMobile) return const SizedBox(height: 0, width: 0);
    return SizedBox(
      width: 64.w,
      child: Stack(children: [
        leftNavBg,
        leftNavIcon,
      ]),
    );
  }

  Widget get leftNavBg {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: Column(children: [
        AnimatedBuilder(
          animation: chatNotifier.animationController,
          builder: (context, c) {
            return SizedBox(
              height: chatNotifier.animationOffset.value + 6.w,
            );
          },
        ),
        Stack(children: [
          Material(
            color: Colors.grey.shade200,
            child: SizedBox(
              height: 10.w,
              width: 64.w,
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12.w),
            ),
            child: SizedBox(
              height: 10.w,
              width: 64.w,
            ),
          ),
        ]),
        Container(
          height: 48.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.w),
              bottomLeft: Radius.circular(12.w),
            ),
          ),
        ),
        Stack(children: [
          Material(
            color: Colors.grey.shade200,
            child: SizedBox(
              height: 10.w,
              width: 60.w,
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12.w),
            ),
            child: SizedBox(
              height: 10.w,
              width: 60.w,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget get leftNavIcon {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.w),
      itemCount: DeviceManager().connectedDevice.length + 1,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => chatNotifier.onLeftNavIconTap(index),
          child: Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              child: index == 0
                  ? Image.asset(
                      'assets/icon/all.png',
                      width: 24.w,
                      height: 24.w,
                      package: Config.flutterPackage,
                    )
                  : Image.asset(
                      getIcon(
                          DeviceManager().connectedDevice[index - 1].platform),
                      width: 24.w,
                      height: 24.w,
                      package: Config.flutterPackage,
                    ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 10.w);
      },
    );
  }

  Widget get chatBody {
    return Expanded(
      child: Column(children: [
        Expanded(child: chatList),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 64.w,
                maxHeight: 240.w,
              ),
              child: chatEditBox,
            ),
          ),
        ),
      ]),
    );
  }

  Widget get chatList {
    return GestureDetector(
      onTap: () {
        chatNotifier.focusNode.unfocus();
      },
      child: Material(
        borderRadius: BorderRadius.circular(10.w),
        color: Colors.grey.shade200,
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20.w),
          controller: chatNotifier.scrollController,
          itemCount: chatNotifier.chatWidgetList.length,
          itemBuilder: (_, index) {
            return chatNotifier.chatWidgetList[index];
          },
        ),
      ),
    );
  }

  Widget get chatEditBox {
    return Material(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.w),
        topRight: Radius.circular(12.w),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.w, 8.w, 8.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: TextField(
                    focusNode: chatNotifier.focusNode,
                    controller: chatNotifier.textEditingController,
                    autofocus: false,
                    maxLines: 8,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: GetPlatform.isWeb ? 16.w : 10.w,
                        horizontal: 12.w,
                      ),
                      hintText: 'shift+enter 即可换行',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                    ),
                    style: const TextStyle(
                      textBaseline: TextBaseline.ideographic,
                    ),
                    onChanged: chatNotifier.onEditTextChanged,
                    onSubmitted: chatNotifier.onEditTextSubmit,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: chatNotifier.onEditBoxIconTap,
                child: Material(
                  borderRadius: BorderRadius.circular(24.w),
                  color: Colors.grey.shade200,
                  child: SizedBox(
                    width: 46.w,
                    height: 46.w,
                    child: chatNotifier.hasInput
                        ? Icon(Icons.send, size: 20.w)
                        : AnimatedBuilder(
                            animation: chatNotifier.menuAnimationController,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateZ(chatNotifier
                                          .menuAnimationController.value *
                                      pi /
                                      4),
                                child: child,
                              );
                            },
                            child: Icon(Icons.add, size: 20.w),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
            ]),
            SizedBox(height: 4.w),
            chatEditMenu,
          ],
        ),
      ),
    );
  }

  Widget get chatEditMenu {
    return AnimatedBuilder(
      animation: chatNotifier.menuAnimationController,
      builder: (context, child) {
        return SizedBox(
          height: 100.w * chatNotifier.menuAnimationController.value,
          child: child,
        );
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16.w),
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: [
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.w),
              onTap: chatNotifier.onMenuChooserSystemFileManager,
              child: Tooltip(
                message: '点击将会调用系统的文件选择器',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 36.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 4.w),
                    Text(
                      '系统管理器',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.w,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (GetPlatform.isAndroid && !GetPlatform.isWeb)
            Theme(
              data: Theme.of(context),
              child: Builder(builder: (context) {
                return SizedBox(
                  width: 80.w,
                  height: 80.w,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.w),
                    onTap: chatNotifier.onMenuChooserCustomFileManager,
                    child: Tooltip(
                      message: '点击将调用自实现的文件选择器',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_copy,
                            size: 36.w,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(height: 4.w),
                          Text(
                            '内部管理器',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.w,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          if (!GetPlatform.isWeb)
            SizedBox(
              width: 80.w,
              height: 80.w,
              child: InkWell(
                borderRadius: BorderRadius.circular(10.w),
                onTap: chatNotifier.onMenuChooserFolder,
                child: Tooltip(
                  message: '点击将调用自实现的文件夹选择器',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_copy,
                        size: 36.w,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: 4.w),
                      Text(
                        '文件夹',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.w,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  String getIcon(DevicePlatform platform) {
    switch (platform) {
      case DevicePlatform.mobile:
        return 'assets/icon/phone.png';
      case DevicePlatform.desktop:
        return 'assets/icon/computer.png';
      case DevicePlatform.web:
        return 'assets/icon/browser.png';
      default:
        return 'assets/icon/computer.png';
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatNotifier.disposeNotifier();
  }
}

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
    chatWidgetList.clear();
    // 设置连接状态
    connectState.value = true;

    if (GetPlatform.isWeb) {
      joinChatRoomWeb();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
    await getSuccessBindPort();
    logI('shelf will server with $shelfBindPort port');
    logI('file server started with $fileServerPort port');
    if (!InitServer().initLock.isCompleted) {
      InitServer().initLock.complete("初始化完毕");
    }
  }

  // Web端加入聊天室
  void joinChatRoomWeb() {
    String url = "http://192.168.3.6:12000/";
    if (!kReleaseMode) {
      url = "http://localhost:12000/";
    }
    Uri uri = Uri.parse(url);
    DeviceManager().onConnect(
      id: InitServer().deviceId,
      name: InitServer().deviceName,
      platform: DevicePlatform.web,
      uri: 'http://${uri.host}',
      port: uri.port,
    );

    sendJoinEvent('http://${uri.host}:${uri.port}');
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
        notifyListeners();
        return;
      }
    } else if (message is NotifyMessage) {
      if (GetPlatform.isWeb) {}
    }

    // 往聊天列表中添加一条消息
    Widget? itemWidget = MessageFactory.getMessageItem(message, false);
    if (itemWidget != null && message.deviceId != InitServer().deviceId) {
      chatWidgetList.add(itemWidget);
      scrollController.scrollToEnd();
      notifyListeners();
    }
  }

  void sendJoinEvent(String url) async {
    ChatServer().sendJoinEvent(
      url,
      addressList,
      shelfBindPort,
      messageBindPort,
    );
  }

  Future<void> getSuccessBindPort() async {
    if (!GetPlatform.isWeb) {
      shelfBindPort = await getSafePort(
        Config.shelfPortRangeStart,
        Config.shelfPortRangeEnd,
      );
      ChatServer().checkToken(shelfBindPort);
      fileServerPort = await getSafePort(
        Config.filePortRangeStart,
        Config.filePortRangeEnd,
      );
      startFileServer(fileServerPort);
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

  void sendTextMsg() {
    if (textEditingController.text.isEmpty) {
      showToast("发送内容不能为空");
      return;
    }
    TextMessage textMessage = TextMessage(
      content: textEditingController.text,
      fromDevice: InitServer().deviceName,
    );
    textMessage.platform = GetPlatform.type.index;
    textMessage.deviceId = InitServer().deviceId;
    messageQueue.add(textMessage.toJson());
    Widget? messageItem = MessageFactory.getMessageItem(textMessage, true);
    if (messageItem != null) chatWidgetList.add(messageItem);
    DeviceManager().sendData(textMessage.toJson());
    notifyListeners();
    textEditingController.clear();
    scrollController.scrollToEnd();
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
      // todo
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
