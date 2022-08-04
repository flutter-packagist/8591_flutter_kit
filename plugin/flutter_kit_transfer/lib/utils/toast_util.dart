import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

FToast fToast = FToast();

void initToast(BuildContext context) {
  fToast.init(context);
}

void showToast(String msg) {
  fToast.showToast(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black38,
      ),
      child: Text(msg, style: const TextStyle(color: Colors.white)),
    ),
    gravity: ToastGravity.CENTER,
    toastDuration: const Duration(seconds: 2),
  );
}
