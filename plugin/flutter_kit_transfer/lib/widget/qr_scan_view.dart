import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/platform/platform.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// 扫码页面
class QRScanView extends StatefulWidget {
  const QRScanView({Key? key}) : super(key: key);

  @override
  QRScanViewState createState() => QRScanViewState();
}

class QRScanViewState extends State<QRScanView> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScan');
  QRViewController? controller;

  late Animation<Alignment> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (GetPlatform.isAndroid) {
      controller?.pauseCamera();
    } else if (GetPlatform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      qrScan,
      qrAnimation,
    ]);
  }

  Widget get qrScan {
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        this.controller = controller;
        if (GetPlatform.isAndroid) {
          this.controller?.resumeCamera();
        }
        controller.scannedDataStream.listen((scanData) {
          controller.stopCamera();
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(scanData.code);
          }
        });
      },
    );
  }

  /// 扫码的动画
  Widget get qrAnimation {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(
            color: Colors.black.withAlpha(100),
            width: MediaQuery.of(context).size.height / 2 -
                MediaQuery.of(context).size.width / 2 +
                40.w,
          ),
          bottom: BorderSide(
            color: Colors.black.withAlpha(100),
            width: MediaQuery.of(context).size.height / 2 -
                MediaQuery.of(context).size.width / 2 +
                40.w,
          ),
          start: BorderSide(
            color: Colors.black.withAlpha(100),
            width: 40.w,
          ),
          end: BorderSide(
            color: Colors.black.withAlpha(100),
            width: 40.w,
          ),
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 80.w,
        height: MediaQuery.of(context).size.width - 80.w,
        child: Stack(
          alignment: _animation.value,
          children: <Widget>[
            Container(
              color: Colors.red,
              width: MediaQuery.of(context).size.width - 80.w,
              height: 2.w,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
