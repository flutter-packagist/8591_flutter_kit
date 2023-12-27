import 'dart:math';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/log_util.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:get/get.dart';

import '../config/config.dart';
import '../service/device_manager.dart';
import 'chat_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  ChatController get controller {
    if (Get.isRegistered<ChatController>()) {
      return Get.find<ChatController>();
    }
    return Get.put<ChatController>(ChatController());
  }

  @override
  void initState() {
    Get.put<ChatController>(ChatController());
    controller.context = context;
    initAnimation();
    super.initState();
  }

  void initAnimation() {
    controller.navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    controller.navAnimationOffset = Tween<double>(begin: 0, end: 0)
        .animate(controller.navAnimationController);
    controller.menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (controller) => dropWrapper,
    );
  }

  Widget get dropWrapper {
    return DropTarget(
      onDragEntered: controller.onDragEntered,
      onDragExited: controller.onDragExited,
      onDragDone: controller.onDragDone,
      child: Stack(children: [
        body,
        if (controller.isDragging)
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
      ]),
    );
  }

  Widget get body {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: SafeArea(
        child: Row(children: [
          leftNav,
          Expanded(child: chatBody),
        ]),
      ),
    );
  }

  PreferredSizeWidget get appBar {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(children: [
        Text(
          '全部设备',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(width: 4.w),
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: controller.connectState ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(10.w),
          ),
        ),
      ]),
      actions: [
        Offstage(
          offstage: GetPlatform.isWeb,
          child: IconButton(
            onPressed: controller.onQrcodeIconTap,
            icon: Icon(Icons.qr_code, size: 20.w, color: Colors.black),
            splashRadius: 20.w,
          ),
        ),
        Offstage(
          offstage: GetPlatform.isWeb,
          child: IconButton(
            onPressed: controller.onMoreIconTap,
            icon: Icon(Icons.more_vert, size: 20.w, color: Colors.black),
            splashRadius: 20.w,
          ),
        ),
      ],
    );
  }

  Widget get leftNav {
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
          animation: controller.navAnimationController,
          builder: (context, c) {
            return SizedBox(
              height: controller.navAnimationOffset.value + 6.w,
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
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.w),
      itemCount: DeviceManager().connectedDevice.length,
      itemBuilder: (context, index) {
        var platform = DeviceManager().connectedDevice[index].platform;
        return GestureDetector(
          onTap: () => controller.onLeftNavIconTap(index),
          child: Container(
            width: 48.w,
            height: 48.w,
            margin: EdgeInsets.only(left: 10.w),
            alignment: Alignment.center,
            child: Image.asset(
              controller.deviceIcon(platform),
              width: 24.w,
              height: 24.w,
              package: Config.flutterPackage,
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
    return Column(children: [
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
    ]);
  }

  Widget get chatList {
    logW("chatList refresh: ${controller.chatWidgetList.length}");
    logW("chatList controller: ${controller.hashCode}");
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        borderRadius: BorderRadius.circular(10.w),
        color: Colors.grey.shade200,
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20.w),
          controller: controller.scrollController,
          itemCount: controller.chatWidgetList.length,
          itemBuilder: (_, index) {
            return controller.chatWidgetList[index];
          },
        ),
      ),
    );
  }

  Widget get chatEditBox {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w),
          topRight: Radius.circular(12.w),
        ),
      ),
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
                  focusNode: controller.focusNode,
                  controller: controller.textEditingController,
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
                  onChanged: controller.onTextFieldChanged,
                  onSubmitted: controller.onTextFieldSubmitted,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: controller.onSubmitIconTap,
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24.w),
                ),
                child: controller.hasInput
                    ? Icon(Icons.send, size: 20.w)
                    : AnimatedBuilder(
                        animation: controller.menuAnimationController,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateZ(
                                  controller.menuAnimationController.value *
                                      pi /
                                      4),
                            child: child,
                          );
                        },
                        child: Icon(Icons.add, size: 20.w),
                      ),
              ),
            ),
            SizedBox(width: 4.w),
          ]),
          SizedBox(height: 4.w),
          chatEditMenu,
        ],
      ),
    );
  }

  Widget get chatEditMenu {
    return AnimatedBuilder(
      animation: controller.menuAnimationController,
      builder: (context, child) {
        return SizedBox(
          height: 100.w * controller.menuAnimationController.value,
          child: child,
        );
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16.w),
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: [
          SizedBox(
            width: 90.w,
            height: 90.w,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.w),
              onTap: controller.onMenuChooserSystemFileManager,
              child: Tooltip(
                message: '点击将会调用系统的文件选择器',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_copy,
                      size: 30.w,
                      color: Colors.black,
                    ),
                    SizedBox(height: 6.w),
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
        ]),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ChatController>();
    super.dispose();
  }
}
