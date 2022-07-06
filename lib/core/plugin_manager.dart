import 'pluggable.dart';

class PluginManager {
  static final PluginManager _instance = PluginManager._();

  factory PluginManager() => _instance;

  PluginManager._();

  Map<String, Pluggable?> get pluginsMap => _pluginsMap;

  final Map<String, Pluggable?> _pluginsMap = {};

  Pluggable? _activatedPluggable;

  String? get activatedPluggableName => _activatedPluggable?.name;

  /// Register a single [plugin]
  void register(Pluggable plugin) {
    if (plugin.name.isEmpty) {
      return;
    }
    _pluginsMap[plugin.name] = plugin;
  }

  /// Register multiple [plugins]
  void registerAll(List<Pluggable> plugins) {
    for (final plugin in plugins) {
      register(plugin);
    }
  }

  void activatePluggable(Pluggable pluggable) {
    _activatedPluggable = pluggable;
  }

  void deactivatePluggable(Pluggable pluggable) {
    if (_activatedPluggable?.name == pluggable.name) {
      _activatedPluggable = null;
    }
  }
}
