import 'package:flutter_kit/flutter_kit.dart';
import 'package:vm_service/vm_service.dart';

class CodeSearchService with VMServiceWrapper {
  Future<String?> getIdWithClassName(String className) async {
    final classList = await serviceWrapper.getClassList();
    final classes = classList.classes;
    if (classes == null) return null;
    for (final cls in classes) {
      if (cls.name == className) return cls.id;
    }
    return null;
  }

  Future<String?> getScriptIdWithFileName(String fileName) async {
    ScriptList scriptList = await serviceWrapper.getScripts();
    final scripts = scriptList.scripts!;
    for (final script in scripts) {
      if (script.uri!.contains(fileName)) return script.id;
    }
    return null;
  }

  Future<Map<String?, String?>> getScriptIdsWithKeyword(String keyword) async {
    ScriptList scriptList = await serviceWrapper.getScripts();
    var result = <String?, String?>{};
    for (var script in scriptList.scripts!) {
      if (script.uri!.contains(keyword)) {
        result[script.uri] = script.id;
      }
    }
    return result;
  }

  Future<String?> getSourceCodeWithScriptId(String scriptId) async {
    Obj script = await serviceWrapper.getObject(scriptId);
    if (script is Script) {
      return script.source;
    }
    return null;
  }
}
