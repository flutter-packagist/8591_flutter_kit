import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:flutter_kit/core/pluggable_message_service.dart';
import 'package:flutter_kit/core/plugin_manager.dart';
import 'package:flutter_kit/util/icon_cache.dart';
import 'package:flutter_kit/util/store_manager.dart';

import 'draggable_widget.dart';

typedef MenuAction = void Function(Pluggable?);
typedef CloseAction = void Function();

class MenuPage extends StatefulWidget {
  final MenuAction? action;
  final CloseAction? closeAction;

  const MenuPage({Key? key, this.action, this.closeAction}) : super(key: key);

  @override
  MenuPageState createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final PluginStoreManager _storeManager = PluginStoreManager();
  List<Pluggable?> _dataList = [];

  @override
  void initState() {
    super.initState();
    _handleData();
  }

  void _handleData() async {
    List<Pluggable?> dataList = [];
    List<String>? pluginList = await _storeManager.fetchStorePlugins();
    if (pluginList == null || pluginList.isEmpty) {
      dataList = PluginManager().pluginsMap.values.toList();
    } else {
      for (var plugin in pluginList) {
        bool contain = PluginManager().pluginsMap.containsKey(plugin);
        if (contain) {
          dataList.add(PluginManager().pluginsMap[plugin]);
        }
      }
      for (var key in PluginManager().pluginsMap.keys) {
        if (!pluginList.contains(key)) {
          dataList.add(PluginManager().pluginsMap[key]);
        }
      }
    }
    _saveData(dataList);
    setState(() {
      _dataList = dataList;
    });
  }

  void _saveData(List<Pluggable?> pluginList) {
    List<String> dataList = pluginList.map((plugin) => plugin!.name).toList();
    if (dataList.isEmpty) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      _storeManager.storePlugins(dataList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      onClose: () {
        widget.closeAction?.call();
      },
      child: _dataList.isEmpty
          ? const EmptyPlaceholder()
          : ColoredBox(
              color: Colors.white,
              child: DraggableGridView(
                _dataList,
                childAspectRatio: 0.9,
                canAccept: (oldIndex, newIndex) {
                  return true;
                },
                dragCompletion: (dataList) {
                  _saveData(dataList as List<Pluggable?>);
                },
                itemBuilder: (context, dynamic data) {
                  return GestureDetector(
                    onTap: () {
                      widget.action!(data);
                      PluggableMessageService().resetCounter(data);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: MenuCell(pluginData: data),
                  );
                },
              ),
            ),
    );
  }
}

class MenuCell extends StatelessWidget {
  final Pluggable? pluginData;

  const MenuCell({Key? key, this.pluginData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Colors.grey.withOpacity(0.25);
    return LayoutBuilder(builder: (_, constraints) {
      return Material(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 40,
              width: 40,
              child: IconCache.icon(pluginData!),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                pluginData!.displayName,
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ConsolePanel extends StatelessWidget {
  final VoidCallback? onClose;
  final Widget? title;
  final List<Widget>? actions;
  final Widget child;

  const ConsolePanel({
    Key? key,
    this.onClose,
    this.title,
    this.actions,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black26,
      child: SafeArea(
        child: Column(children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              color: Color(0xffeee8ed),
            ),
            width: MediaQuery.of(context).size.width,
            height: 36,
            child: NavigationToolbar(
              leading: leading(),
              middle: title,
              trailing: trailing(),
            ),
          ),
          Expanded(child: child),
        ]),
      ),
    );
  }

  Widget leading() {
    return RawMaterialButton(
      onPressed: onClose,
      elevation: 0,
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      fillColor: const Color(0xffff5a52),
      constraints: const BoxConstraints(
        minHeight: 18,
        minWidth: 18,
      ),
      // child: const Icon(
      //   Icons.close,
      //   color: Colors.black54,
      //   size: 16,
      // ),
    );
  }

  Widget? trailing() {
    Widget? action;
    if (actions != null && actions!.isNotEmpty) {
      action = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions!,
      );
    }
    return action;
  }
}

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: const Text('无内容'),
    );
  }
}
