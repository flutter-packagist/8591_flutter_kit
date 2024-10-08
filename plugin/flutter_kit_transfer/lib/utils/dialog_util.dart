import 'package:flutter/material.dart';
import 'package:flutter_kit_transfer/utils/screen_util.dart';

enum PageTransitionType {
  // 缩放动画
  scale,
  // 渐变透明
  fade,
  // 旋转
  rotate,
  // 从上到下
  top,
  // 从左到右
  left,
  // 从下到上
  bottom,
  // 从右到左
  right,
  // 无动画
  none,
  // default 系统动画
  sysDefault,
  // menu 菜单动画
  menu,
}

Future<T?> showAnimationDialog<T>(
  BuildContext context, {
  required Widget child,
  Color? barrierColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  PageTransitionType transitionType = PageTransitionType.scale,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return child;
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation1, animation2, child) {
      return _buildDialogTransitions(
        context,
        animation1,
        animation2,
        child,
        transitionType,
      );
    },
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}

Widget _buildDialogTransitions(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  PageTransitionType type,
) {
  if (type == PageTransitionType.fade) {
    // 渐变效果
    return FadeTransition(
      // 从0开始到1
      opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        // 传入设置的动画
        parent: animation,
        // 设置效果，快进漫出   这里有很多内置的效果
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  } else if (type == PageTransitionType.scale) {
    return ScaleTransition(
      scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  } else if (type == PageTransitionType.left) {
    // 左右滑动动画效果
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      ),
      child: child,
    );
  } else if (type == PageTransitionType.right) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  } else if (type == PageTransitionType.top) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  } else if (type == PageTransitionType.bottom) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  } else if (type == PageTransitionType.menu) {
    final curvedValue = Curves.easeIn.transform(animation.value);
    return Transform(
      transform: Matrix4.translationValues(0.0, curvedValue * 20, 0.0),
      child: Opacity(
        opacity: animation.value,
        child: Container(
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.w,
            right: 10.w,
          ),
          child: child,
        ),
      ),
    );
  } else {
    return child;
  }
}
