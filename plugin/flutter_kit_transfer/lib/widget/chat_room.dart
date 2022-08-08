import 'dart:math';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

import '../config/config.dart';
import '../controller/chat_controller.dart';
import '../platform/platform.dart';
import '../service/device_manager.dart';

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
          // if (GetPlatform.isAndroid && !GetPlatform.isWeb)
          //   Theme(
          //     data: Theme.of(context),
          //     child: Builder(builder: (context) {
          //       return SizedBox(
          //         width: 80.w,
          //         height: 80.w,
          //         child: InkWell(
          //           borderRadius: BorderRadius.circular(10.w),
          //           onTap: chatNotifier.onMenuChooserCustomFileManager,
          //           child: Tooltip(
          //             message: '点击将调用自实现的文件选择器',
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Icon(
          //                   Icons.file_copy,
          //                   size: 36.w,
          //                   color: Theme.of(context).primaryColor,
          //                 ),
          //                 SizedBox(height: 4.w),
          //                 Text(
          //                   '内部管理器',
          //                   style: TextStyle(
          //                     color: Colors.black,
          //                     fontWeight: FontWeight.bold,
          //                     fontSize: 12.w,
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     }),
          //   ),
          // if (!GetPlatform.isWeb)
          //   SizedBox(
          //     width: 80.w,
          //     height: 80.w,
          //     child: InkWell(
          //       borderRadius: BorderRadius.circular(10.w),
          //       onTap: chatNotifier.onMenuChooserFolder,
          //       child: Tooltip(
          //         message: '点击将调用自实现的文件夹选择器',
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Icon(
          //               Icons.folder_copy,
          //               size: 36.w,
          //               color: Theme.of(context).primaryColor,
          //             ),
          //             SizedBox(height: 4.w),
          //             Text(
          //               '文件夹',
          //               style: TextStyle(
          //                 color: Colors.black,
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 12.w,
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
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
