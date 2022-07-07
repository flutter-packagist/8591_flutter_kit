// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:flutter_kit/core/pluggable_message_service.dart';
import 'package:flutter_kit/core/plugin_manager.dart';
import 'package:flutter_kit/util/constants.dart';
import 'package:flutter_kit/util/store_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'icon.dart' as icon;
import 'menu_page.dart';

const defaultLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  DefaultCupertinoLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

final GlobalKey rootKey = GlobalKey();
final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

/// Wrap your App widget. If [enable] is false, the function will return [child].
class KitWidget extends StatefulWidget {
  const KitWidget({
    Key? key,
    required this.child,
    this.enable = true,
    this.supportedLocales,
    this.localizationsDelegates = defaultLocalizationsDelegates,
  }) : super(key: key);

  final Widget child;
  final bool enable;
  final Iterable<Locale>? supportedLocales;
  final Iterable<LocalizationsDelegate> localizationsDelegates;

  @override
  _KitWidgetState createState() => _KitWidgetState();
}

class _KitWidgetState extends State<KitWidget> {
  late Widget _child;

  VoidCallback? _onMetricsChanged;

  OverlayEntry _overlayEntry = OverlayEntry(builder: (ctx) => Container());

  @override
  void initState() {
    super.initState();
    _replaceChild();
    _injectOverlay();

    _onMetricsChanged = WidgetsBinding.instance.window.onMetricsChanged;
    WidgetsBinding.instance.window.onMetricsChanged = () {
      if (_onMetricsChanged != null) {
        _onMetricsChanged!();
        _replaceChild();
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    if (_onMetricsChanged != null) {
      WidgetsBinding.instance.window.onMetricsChanged = _onMetricsChanged;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(KitWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.enable
        ? PluggableMessageService().resetListener()
        : PluggableMessageService().clearListener();
    if (widget.enable != oldWidget.enable && widget.enable) {
      _injectOverlay();
    }
    if (widget.child != oldWidget.child) {
      _replaceChild();
    }
    if (!widget.enable) {
      _removeOverlay();
    }
  }

  void _replaceChild() {
    final nestedWidgets = PluginManager().pluginsMap.values.where((value) {
      return value != null && value is PluggableWithNestedWidget;
    }).toList();
    Widget layoutChild = _buildLayout(
      widget.child,
      widget.supportedLocales,
      widget.localizationsDelegates,
    );
    for (var item in nestedWidgets) {
      if (item!.name != PluginManager().activatedPluggableName) {
        continue;
      }
      if (item is PluggableWithNestedWidget) {
        layoutChild = item.buildNestedWidget(layoutChild);
        break;
      }
    }
    _child = Directionality(
      textDirection: TextDirection.ltr,
      child: layoutChild,
    );
  }

  Stack _buildLayout(Widget child, Iterable<Locale>? supportedLocales,
      Iterable<LocalizationsDelegate> delegates) {
    return Stack(
      children: <Widget>[
        RepaintBoundary(key: rootKey, child: child),
        MediaQuery(
          data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
          child: Localizations(
            locale: supportedLocales?.first ?? const Locale('en', 'US'),
            delegates: delegates.toList(),
            child: ScaffoldMessenger(child: Overlay(key: overlayKey)),
          ),
        ),
      ],
    );
  }

  void _injectOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.enable) {
        _overlayEntry = OverlayEntry(
          builder: (_) => Material(
            type: MaterialType.transparency,
            child: _ContentPage(
              refreshChildLayout: () {
                _replaceChild();
                setState(() {});
              },
            ),
          ),
        );
        overlayKey.currentState?.insert(_overlayEntry);
      }
    });
  }

  void _removeOverlay() => _overlayEntry.remove();

  @override
  Widget build(BuildContext context) => _child;
}

class _ContentPage extends StatefulWidget {
  const _ContentPage({Key? key, this.refreshChildLayout}) : super(key: key);

  final VoidCallback? refreshChildLayout;

  @override
  __ContentPageState createState() => __ContentPageState();
}

class __ContentPageState extends State<_ContentPage> {
  final PluginStoreManager _storeManager = PluginStoreManager();
  final Widget _empty = Container();
  Size _windowSize = windowSize;
  double _dx = 0;
  double _dy = 0;
  bool _showedMenu = false;
  Pluggable? _currentSelected;
  Widget? _currentWidget;
  Widget? _menuPage;
  BuildContext? _context;

  void dragEvent(DragUpdateDetails details) {
    _dx = details.globalPosition.dx - dotSize.width / 2;
    _dy = details.globalPosition.dy - dotSize.height / 2;
    setState(() {});
  }

  void dragEnd(DragEndDetails details) {
    if (_dx + dotSize.width / 2 < _windowSize.width / 2) {
      _dx = margin;
    } else {
      _dx = _windowSize.width - dotSize.width - margin;
    }
    if (_dy + dotSize.height > _windowSize.height) {
      _dy = _windowSize.height - dotSize.height - margin;
    } else if (_dy < 0) {
      _dy = margin;
    }

    _storeManager.storeFloatingDotPos(_dx, _dy);

    setState(() {});
  }

  void onTap() {
    if (_currentSelected != null) {
      PluginManager().deactivatePluggable(_currentSelected!);
      if (widget.refreshChildLayout != null) {
        widget.refreshChildLayout!();
      }
      _currentSelected = null;
      _currentWidget = _empty;
      setState(() {});
      return;
    }
    _showedMenu = !_showedMenu;
    _updatePanelWidget();
  }

  void _updatePanelWidget() {
    setState(() {
      _currentWidget = _showedMenu ? _menuPage : _empty;
    });
  }

  Future<void> onMenuTap(pluginData) async {
    if (pluginData is PluggableWithAnywhereDoor) {
      dynamic result;
      if (pluginData.routeArgs != null) {
        result = await pluginData.navigator?.pushNamed(
          pluginData.routeName!,
          arguments: pluginData.routeArgs,
        );
      } else if (pluginData.route != null) {
        result = await pluginData.navigator?.push(pluginData.route!);
      }
      pluginData.popResultReceive(result);
    } else {
      _currentSelected = pluginData;
      if (_currentSelected != null) {
        PluginManager().activatePluggable(_currentSelected!);
      }
      _handleAction(_context, pluginData!);
      if (widget.refreshChildLayout != null) {
        widget.refreshChildLayout!();
      }
      pluginData.onTrigger();
    }
  }

  void _handleAction(BuildContext? context, Pluggable data) {
    _currentWidget = data.buildWidget(context);
    setState(() {
      _showedMenu = false;
    });
  }

  Widget _logoWidget() {
    return Image(
      height: 32,
      width: 32,
      image: _currentSelected != null
          ? _currentSelected!.iconImageProvider
          : MemoryImage(icon.iconBytes),
    );
  }

  @override
  void initState() {
    super.initState();
    _storeManager.fetchFloatingDotPos().then((value) {
      if (value == null || value.split(',').length != 2) {
        return;
      }
      final x = double.parse(value.split(',').first);
      final y = double.parse(value.split(',').last);
      if (MediaQuery.of(context).size.height - dotSize.height < y ||
          MediaQuery.of(context).size.width - dotSize.width < x) {
        return;
      }
      _dx = x;
      _dy = y;
      setState(() {});
    });
    _dx = _windowSize.width - dotSize.width - margin * 4;
    _dy = _windowSize.height - dotSize.height - bottomDistance;
    _menuPage = MenuPage(
      action: onMenuTap,
      closeAction: () {
        _showedMenu = false;
        _updatePanelWidget();
      },
    );
    _currentWidget = _empty;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    if (_windowSize.isEmpty) {
      _dx = MediaQuery.of(context).size.width - dotSize.width - margin * 4;
      _dy =
          MediaQuery.of(context).size.height - dotSize.height - bottomDistance;
      _windowSize = MediaQuery.of(context).size;
    }
    return SizedBox(
      width: _windowSize.width,
      height: _windowSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _currentWidget!,
          Positioned(
            left: _dx,
            top: _dy,
            child: Tooltip(
              message: 'Open kit panel',
              child: GestureDetector(
                onTap: onTap,
                onVerticalDragEnd: dragEnd,
                onHorizontalDragEnd: dragEnd,
                onHorizontalDragUpdate: dragEvent,
                onVerticalDragUpdate: dragEvent,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                  width: dotSize.width,
                  height: dotSize.height,
                  child: Center(child: _logoWidget()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
