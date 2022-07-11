import 'package:flutter_kit_code/service/code_search_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeSearchService', () {
    const fileName = 'code_search_service.dart';
    const className = 'CodeSearchService';

    test('getIdWithClassName', () async {
      final id = await CodeSearchService().getIdWithClassName(className);
      expect(id, isNotNull);
    });
    test('getScriptIdWithFileName', () async {
      final id = await CodeSearchService().getScriptIdWithFileName(fileName);
      expect(id, isNotNull);
    });
    test('getScriptIdsWithKeyword', () async {
      final id = await CodeSearchService().getScriptIdsWithKeyword(fileName);
      expect(id, isA<Map>());
    });
    test('getSourceCodeWithScriptId', () async {
      final id = await CodeSearchService().getScriptIdWithFileName(fileName);
      expect(id, isNotNull);
      final sourceCode = await CodeSearchService().getSourceCodeWithScriptId(id!);
      print("sourceCode: \n$sourceCode");
      expect(sourceCode, isNotNull);
    });
    test('getSourceCodeWithKeyword', () async {
      final ids = await CodeSearchService().getScriptIdsWithKeyword(fileName);
      expect(ids, isNotNull);
      final id = ids.keys.elementAt(0);
      expect(id, isNotNull);
      final sourceCode = await CodeSearchService().getSourceCodeWithScriptId(id!);
      print("sourceCode: \n$sourceCode");
      expect(sourceCode, isNotNull);
    });
  });
}
