# flutter_kit

Flutter应用内调试工具（当前基于Flutter版本：3.0.x）

本项目fork自 [flutter_ume](https://github.com/bytedance/flutter_ume)
，并做了部分调整，以适应自身项目的需求，同时通过对项目的调整，使其在release版本中也能够正常的使用部分功能。

## 功能介绍

这里将功能分为两部分。

1. 需要借助 VM Service 的工具，只能在debug版本中使用。
2. 可以直接在Release中使用的工具。❗️❗️❗️❗️❗️（当然为了避免线上出现问题，请在做好充分测试之后再上线）

### 只能在debug上使用的功能

<table border="1" width="100%">
    <tr>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot4.png" width="80%" alt="代码查看" /></br>代码查看</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot5.png" width="80%" alt="内存信息" /></br>内存信息</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot6.png" width="80%" alt="性能浮层" /></br>性能浮层</td>
    </tr>
</table>

### Release上能使用的功能

<table border="1" width="100%">
    <tr>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot1.png" width="80%" alt="系统设置" /></br>系统设置</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot2.png" width="80%" alt="CPU 信息" /></br>CPU 信息</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot3.png" width="80%" alt="设备信息" /></br>设备信息</td>
    </tr>
    <tr>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot7.png" width="80%" alt="dio网络请求" /></br>dio网络请求</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot8.png" width="80%" alt="日志打印" /></br>日志打印</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot9.png" width="80%" alt="颜色提取" /></br>颜色提取</td>
    </tr>
    <tr>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot10.png" width="80%" alt="局域网数据传输" /></br>局域网数据传输</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/raw/main/Screenshot11.png" width="80%" alt="应用内H5入口" /></br>应用内H5入口</td>
    </tr>
</table>

## 使用方式

1. 修改 `pubspec.yaml`，添加依赖

```yaml
dev_dependencies:

  flutter_kit:
    version: ^0.0.2
    hosted:
      name: flutter_kit
      url: http://192.168.8.75:4000/
  flutter_kit_code:
    version: ^0.0.1
    hosted:
      name: flutter_kit_code
      url: http://192.168.8.75:4000/
  flutter_kit_device:
    version: ^0.0.1
    hosted:
      name: flutter_kit_device
      url: http://192.168.8.75:4000/
  flutter_kit_dio:
    version: ^0.0.1
    hosted:
      name: flutter_kit_dio
      url: http://192.168.8.75:4000/
  flutter_kit_transfer:
    version: ^0.0.1
    hosted:
      name: flutter_kit_transfer
      url: http://192.168.8.75:4000/
  flutter_kit_log:
    version: ^0.0.1
    hosted:
      name: flutter_kit_log
      url: http://192.168.8.75:4000/
  flutter_kit_performance:
    version: ^0.0.1
    hosted:
      name: flutter_kit_performance
      url: http://192.168.8.75:4000/
  flutter_kit_tools:
    version: ^0.0.1
    hosted:
      name: flutter_kit_tools
      url: http://192.168.8.75:4000/
```

2. 执行 `flutter pub get`


3. 引入包

```dart
import 'package:flutter_ume/flutter_ume.dart'; // flutter_kit 基础包
import 'package:flutter_kit_code/flutter_kit_code.dart'; // 代码查看
import 'package:flutter_kit_device/flutter_kit_device.dart'; // 设备信息插件包
import 'package:flutter_kit_dio/flutter_kit_dio.dart'; // Dio 网络请求调试工具
import 'package:flutter_kit_transfer/flutter_kit_transfer.dart'; // 局域网数据传输
import 'package:flutter_kit_log/flutter_kit_log.dart'; // 控制台log输出及log打印工具类
import 'package:flutter_kit_performance/flutter_kit_performance.dart'; // 性能插件包
import 'package:flutter_kit_tools/flutter_kit_tools.dart'; // 通用工具
```

4. 代码中初始化

```dart
void main() {
  PluginManager().registerAll([
    const CpuInfoPanel(),
    const DeviceInfoPanel(),
    const CodeDisplayPanel(),
    const MemoryPanel(),
    const Performance(),
    const ColorPicker(),
    DioInspector(dio: dio),
    Console(),
    const TransferPanel(packageName: "com.example.example"),
    const SettingPanel(),
    const HtmlPanel(),
  ]);
  runApp(const KitWidget(enable: true, child: MyApp()));
}
```

5. `flutter run` 运行，部分依赖 `VM Service` 的功能，在本地运行时需要加额外的参数 `--no-dds`。

## 插件开发和介绍

1. `flutter create -t package custom_plugin` 创建一个插件包，可以是 `package`，也可以是 `plugin`。

2. 修改插件包的 `pubspec.yaml`，添加依赖：

```yaml
dependencies:
  flutter_kit:
    version: ^0.0.2
    hosted:
      name: flutter_kit
      url: http://192.168.8.75:4000/
```

3. 创建插件配置，实现 `Pluggable` 虚类

```dart
import 'package:flutter_kit/flutter_kit.dart';

class CustomPlugin implements Pluggable {
  CustomPlugin({Key key});

  @override
  Widget buildWidget(BuildContext context) =>
      Container(
        color: Colors.white,
        width: 100,
        height: 100,
        child: Center(
            child: Text('Custom Plugin')
        ),
      ); // 返回插件面板

  @override
  String get name => 'CustomPlugin'; // 插件名称

  @override
  String get displayName => 'CustomPlugin';

  @override
  void onTrigger() {} // 点击插件面板图标时调用

  @override
  ImageProvider<Object> get iconImageProvider => NetworkImage('url'); // 插件图标
}
```

3.1 创建插件配置，实现 `PluggableWithStream` 虚类，其为 `Pluggable` 的子类，主要是用于事件流及事件流的过滤。 如： `flutter_kit_log` 中将
log 等方法打印的日志并发送到控制台，就是通过在控制台监听事件流的方式实现的。

3.2 创建插件配置，实现 `PluggableWithNestedWidget` 虚类，用以实现在 Widget tree 中插入嵌套 Widget，快速接入嵌入式插件。
参考 `flutter_kit_tools`
中的 [ColorPicker](https://code.addcn.com/flutter/flutter_kit/-/blob/master/plugin/flutter_kit_tools/lib/color_picker/color_picker.dart) 。

+ 插件主体类实现 `PluggableWithNestedWidget`
+ 实现 `Widget buildNestedWidget(Widget child)`，在该方法中处理嵌套结构并返回 Widget

3.3 创建插件配置，实现 `PluggableWithAnywhereDoor` 虚类，用以实现直接跳转到某个路由页面。
