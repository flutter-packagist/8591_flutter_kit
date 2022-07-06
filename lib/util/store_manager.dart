import 'package:shared_preferences/shared_preferences.dart';

class PluginStoreManager {
  final String _pluginStoreKey = 'PluginStoreKey';
  final String _floatingDotPos = 'FloatingDotPos';

  final Future<SharedPreferences> _sharedPref = SharedPreferences.getInstance();

  Future<List<String>?> fetchStorePlugins() async {
    final SharedPreferences prefs = await _sharedPref;
    return prefs.getStringList(_pluginStoreKey);
  }

  void storePlugins(List<String> plugins) async {
    if (plugins.isEmpty) return;
    final SharedPreferences prefs = await _sharedPref;
    await prefs.setStringList(_pluginStoreKey, plugins);
  }

  Future<String?> fetchFloatingDotPos() async {
    final SharedPreferences prefs = await _sharedPref;
    return prefs.getString(_floatingDotPos);
  }

  void storeFloatingDotPos(double x, double y) async {
    final SharedPreferences prefs = await _sharedPref;
    prefs.setString(_floatingDotPos, "$x,$y");
  }
}
