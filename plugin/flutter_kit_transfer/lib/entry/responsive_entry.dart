import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/toast_util.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'chat_page.dart';

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
    return ResponsiveBreakpoints.builder(
      child: const ChatPage(),
      breakpoints: const [
        Breakpoint(start: 0, end: 450, name: MOBILE),
        Breakpoint(start: 451, end: 800, name: TABLET),
        Breakpoint(start: 801, end: 1920, name: DESKTOP),
        Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
    );
  }
}
