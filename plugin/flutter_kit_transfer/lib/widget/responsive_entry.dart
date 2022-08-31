import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/toast_util.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'chat_room.dart';

class ResponsiveEntry extends StatefulWidget {
  const ResponsiveEntry({Key? key}) : super(key: key);

  @override
  State<ResponsiveEntry> createState() => _ResponsiveEntryState();
}

class _ResponsiveEntryState extends State<ResponsiveEntry> {

  @override
  void initState() {
    initToast(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper.builder(
      Builder(builder: (context) {
        return const ChatRoom();
      }),
      minWidth: 480,
      defaultScale: false,
      breakpoints: const [
        ResponsiveBreakpoint.resize(300, name: MOBILE),
        ResponsiveBreakpoint.autoScale(600, name: TABLET),
        ResponsiveBreakpoint.resize(600, name: DESKTOP),
      ],
    );
  }
}
