import 'dart:io';

/// 寻找未被占用的端口
Future<int> getSafePort(int rangeStart, int rangeEnd) async {
  if (rangeStart == rangeEnd) {
    // 说明都失败了
    return -1;
  }
  try {
    await ServerSocket.bind(
      '0.0.0.0',
      rangeStart,
      shared: true,
    );
    return rangeStart;
  } catch (e) {
    return await getSafePort(rangeStart + 1, rangeEnd);
  }
}
