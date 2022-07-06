import 'package:flutter/material.dart';
import 'package:flutter_kit/core/pluggable.dart';
import 'package:flutter_kit/core/pluggable_message_service.dart';
import 'package:flutter_kit/core/plugin_manager.dart';
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
            child: Row(children: [
              RawMaterialButton(
                onPressed: () {
                  widget.closeAction?.call();
                },
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
              ),
            ]),
          ),
          Expanded(
            child: _dataList.isEmpty
                ? const EmptyPlaceholder()
                : ColoredBox(
                    color: Colors.white,
                    child: DraggableGridView(
                      _dataList,
                      childAspectRatio: 0.85,
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
                          child: _MenuCell(pluginData: data),
                        );
                      },
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _MenuCell extends StatelessWidget {
  const _MenuCell({Key? key, this.pluginData}) : super(key: key);

  final Pluggable? pluginData;

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Colors.grey.withOpacity(0.25);
    return LayoutBuilder(builder: (_, constraints) {
      return Material(
        color: Colors.white,
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                      height: constraints.maxHeight,
                      width: 0.5,
                      color: lineColor)),
              Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                      height: 0.5,
                      width: constraints.maxWidth,
                      color: lineColor)),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                      height: constraints.maxHeight,
                      width: 0.5,
                      color: lineColor)),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                      height: 0.5,
                      width: constraints.maxWidth,
                      color: lineColor)),
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Container(
                    //     child: IconCache.icon(pluggableInfo: pluginData!),
                    //     height: 40,
                    //     width: 40),
                    Container(
                        margin: const EdgeInsets.only(top: 25),
                        child: Text(pluginData!.displayName,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black)))
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
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
