import 'dart:io';

import 'runtime_environment.dart';

Future<String> exec(String cmd) async {
  String value = '';
  final ProcessResult result = await Process.run(
    'sh',
    ['-c', cmd],
    environment: RuntimeEnv.env(),
  );
  value += result.stdout.toString();
  value += result.stderr.toString();
  return value.trim();
}
