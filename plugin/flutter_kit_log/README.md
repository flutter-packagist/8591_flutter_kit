# flutter_kit_log

## 说明

log 打印依赖于 `logger` 包，用于格式化打印的样式，打印的内容可在 Android Studio 和 APP 内查看。

### 日志打印格式

#### 1. 打印格式1

只输出时间和对应的内容。

```dart
logV("冗余信息，Release模式下不输出");
logD("调试信息，Release模式下不输出");
logI("提示信息，Release模式下会输出");
logW("警告信息，Release模式下会输出");
logE("错误信息，Release模式下会输出");
```

<img src="https://github.com/windows7lake/screenshot/blob/main/flutter_kit_log4.jpg?raw=true" width="40%" />

#### 2. 打印格式2

输出时间和对应的内容，并将内容用分割线包围起来。

```dart
logBoxV("冗余信息，Release模式下不输出");
logBoxD("调试信息，Release模式下不输出");
logBoxI("提示信息，Release模式下会输出");
logBoxW("警告信息，Release模式下会输出");
logBoxE("错误信息，Release模式下会输出");
```

<img src="https://github.com/windows7lake/screenshot/blob/main/flutter_kit_log5.jpg?raw=true" width="60%" />

#### 3. 打印格式3

输出时间和对应的内容以及当前堆栈中调用的方法，并将内容用分割线包围起来。

```dart
logStackV("冗余信息，Release模式下不输出");
logStackD("调试信息，Release模式下不输出");
logStackI("提示信息，Release模式下会输出");
logStackW("警告信息，Release模式下会输出");
logStackE("错误信息，Release模式下会输出");
```

<img src="https://github.com/windows7lake/screenshot/blob/main/flutter_kit_log6.jpg?raw=true" width="90%" />

### 日志打印自定义

内部提供自定义 日志过滤 和 日志输出功能，以及高度自定义的日志格式打印。设置方式如下：

```dart
// 在应用初始化时调用
LogWrapper().logFilter = CustomLogFilter();

// 设置日志过滤级别
class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // 非Debug模式下，只显示warming及以上级别的Log
    if (kReleaseMode && event.level.index <= Level.info.index) {
      return false;
    }
    return event.level.index >= level!.index;
  }
}
```

### APP界面预览

APP内提供log等级筛选和关键字过滤的功能。

<table border="1" width="100%">
    <tr>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/blob/main/flutter_kit_log1.png?raw=true" width="80%" alt="无过滤列表" /></br>无过滤列表</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/blob/main/flutter_kit_log2.jpg?raw=true" width="80%" alt="输出级别过滤" /></br>输出级别过滤</td>
        <td width="33.33%" align="center"><img src="https://github.com/windows7lake/screenshot/blob/main/flutter_kit_log3.jpg?raw=true" width="80%" alt="关键字过滤" /></br>关键字过滤</td>
    </tr>
</table>
