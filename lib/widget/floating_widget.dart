import 'dart:math';

import 'package:flutter/material.dart';

import '../util/constants.dart';
import '../util/store_mixin.dart';
import 'root_widget.dart';

const double _dragBarHeight = 36;

class FloatingWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final List<Widget>? actions;
  final Widget? child;
  final double minimalHeight;

  const FloatingWidget({
    Key? key,
    this.onClose,
    this.actions,
    this.child,
    this.minimalHeight = 120,
  }) : super(key: key);

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> with StoreMixin {
  Size _windowSize = windowSize;
  double _dy = 0;
  bool _fullScreen = false;

  @override
  void initState() {
    fetchWithKey('floating_widget_dy').then((value) {
      if (value != null) {
        _dy = value;
        setState(() {});
      }
    });
    fetchWithKey('floating_widget_fullscreen').then((value) {
      if (value != null) {
        _fullScreen = value;
        setState(() {});
      }
    });
    _dy = _windowSize.height - widget.minimalHeight - _dragBarHeight * 3;
    super.initState();
  }

  void _dragEvent(DragUpdateDetails details) {
    _dy += details.delta.dy;
    _dy = min(
      max(0, _dy),
      MediaQuery.of(context).size.height -
          widget.minimalHeight -
          _dragBarHeight -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom,
    );
    setState(() {});
  }

  void _dragEnd(DragEndDetails details) async {
    await storeWithKey('floating_widget_dy', _dy);
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
      _dy = _windowSize.height - dotSize.height - bottomDistance;
    }
    return SizedBox(
      width: _windowSize.width,
      height: _windowSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 0,
            top: _fullScreen ? 0 : _dy,
            child: _ToolBarContent(
              onClose: widget.onClose,
              onZoom: () {
                _fullScreen = !_fullScreen;
                storeWithKey('floating_widget_fullscreen', _fullScreen);
                setState(() {});
              },
              actions: widget.actions,
              onDragUpdate: _dragEvent,
              onDragEnd: _dragEnd,
              minimalHeight: widget.minimalHeight,
              fullscreen: _fullScreen,
              child: widget.child,
            ),
          )
        ],
      ),
    );
  }
}

class _ToolBarContent extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onZoom;
  final List<Widget>? actions;
  final Widget? child;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final double minimalHeight;
  final bool fullscreen;

  const _ToolBarContent({
    Key? key,
    this.onClose,
    this.onZoom,
    this.actions,
    this.child,
    this.onDragUpdate,
    this.onDragEnd,
    required this.minimalHeight,
    required this.fullscreen,
  }) : super(key: key);

  @override
  State<_ToolBarContent> createState() => _ToolBarContentState();
}

class _ToolBarContentState extends State<_ToolBarContent> {
  Size _windowSize = windowSize;
  Radius radius = const Radius.circular(10);

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
    }
    return SafeArea(
      child: Material(
        borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
        elevation: 20,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: widget.fullscreen
              ? _windowSize.height
              : widget.minimalHeight + _dragBarHeight,
          child: Column(children: [
            toolbar(),
            content(),
          ]),
        ),
      ),
    );
  }

  Widget toolbar() {
    return GestureDetector(
      onVerticalDragUpdate: _dragUpdate,
      onVerticalDragEnd: _dragEnd,
      child: Container(
        height: _dragBarHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: radius),
          color: const Color(0xffeee8ed),
        ),
        child: NavigationToolbar(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RawMaterialButton(
                onPressed: widget.onClose ??
                    contentController.state?.closeCurrentPlugin,
                elevation: 0,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                fillColor: const Color(0xffff5a52),
                constraints: const BoxConstraints(minHeight: 18, minWidth: 18),
              ),
              RawMaterialButton(
                onPressed: () {
                  widget.onZoom?.call();
                  setState(() {});
                },
                elevation: 0,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                fillColor: widget.fullscreen
                    ? const Color(0xffe6c029)
                    : const Color(0xff53c22b),
                constraints: const BoxConstraints(minHeight: 18, minWidth: 18),
              )
            ],
          ),
          trailing: trailing(),
        ),
      ),
    );
  }

  Widget? trailing() {
    Widget? action;
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      action = Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.actions!,
      );
    }
    return action;
  }

  Widget content() {
    return SizedBox(
      height: widget.fullscreen
          ? _windowSize.height -
              _dragBarHeight -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom
          : widget.minimalHeight,
      child: widget.child,
    );
  }

  _dragUpdate(DragUpdateDetails details) {
    if (widget.onDragUpdate != null) widget.onDragUpdate!(details);
  }

  _dragEnd(DragEndDetails details) {
    if (widget.onDragEnd != null) widget.onDragEnd!(details);
  }
}
