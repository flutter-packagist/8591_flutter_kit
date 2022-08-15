import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:platform/platform.dart';
import 'package:system_info2/system_info2.dart';

import 'cpu_info_data.dart';
import 'icon.dart' as icon;

class CpuInfoPanel extends StatefulWidget implements Pluggable {
  final Platform platform;

  const CpuInfoPanel({
    Key? key,
    this.platform = const LocalPlatform(),
  }) : super(key: key);

  @override
  CpuInfoPanelState createState() => CpuInfoPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'CPUInfo';

  @override
  String get displayName => 'CPU信息';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);
}

class CpuInfoPanelState extends State<CpuInfoPanel> {
  var _deviceInfo = <CpuInfoItem>[];

  @override
  void initState() {
    super.initState();
    if (widget.platform.isAndroid) _setupData();
  }

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      child: ColoredBox(
        color: Colors.white,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _deviceInfo.length,
          itemBuilder: (ctx, index) =>
              CpuInfoCell(cpuInfoItem: _deviceInfo[index]),
        ),
      ),
    );
  }

  _setupData() {
    const int megaByte = 1024 * 1024;
    final deviceInfo = <CpuInfoItem>[];
    deviceInfo.addAll([
      CpuInfoItem(
        title: 'Kernel name',
        trailing: SysInfo.kernelArchitecture,
      ),
      CpuInfoItem(
        title: 'Kernel version',
        trailing: SysInfo.kernelVersion,
      ),
      CpuInfoItem(
        title: 'Kernel architecture',
        trailing: SysInfo.kernelArchitecture,
      ),
      CpuInfoItem(
        title: 'Kernel Bitness',
        trailing: SysInfo.kernelBitness.toString(),
      ),
      CpuInfoItem(
        title: 'Operating system name',
        trailing: SysInfo.operatingSystemName,
      ),
      CpuInfoItem(
        title: 'Operating system',
        trailing: SysInfo.operatingSystemVersion,
      ),
      CpuInfoItem(
        title: 'User directory',
        trailing: SysInfo.userDirectory,
      ),
      CpuInfoItem(
        title: 'User id',
        trailing: SysInfo.userId,
      ),
      CpuInfoItem(
        title: 'User name',
        trailing: SysInfo.userName,
      ),
      CpuInfoItem(
        title: 'User space bitness',
        trailing: SysInfo.userSpaceBitness.toString(),
      ),
      CpuInfoItem(
        title: 'Total physical memory',
        trailing: '${SysInfo.getTotalPhysicalMemory() ~/ megaByte} MB',
      ),
      CpuInfoItem(
        title: 'Free physical memory',
        trailing: '${SysInfo.getFreePhysicalMemory() ~/ megaByte} MB',
      ),
      CpuInfoItem(
        title: 'Total virtual memory',
        trailing: '${SysInfo.getTotalVirtualMemory() ~/ megaByte} MB',
      ),
      CpuInfoItem(
        title: 'Free virtual memory',
        trailing: '${SysInfo.getFreeVirtualMemory() ~/ megaByte} MB',
      ),
      CpuInfoItem(
        title: 'Virtual memory used by the process',
        trailing: '${SysInfo.getVirtualMemorySize() ~/ megaByte} MB',
      ),
    ]);

    final cores = SysInfo.cores;
    final coreList = <CpuInfoItem>[];
    for (var core in cores) {
      coreList.addAll([
        CpuInfoItem(
          title: '[CPU ${cores.indexOf(core)}] Architecture',
          trailing: core.architecture.name,
        ),
        CpuInfoItem(
          title: '[CPU ${cores.indexOf(core)}] Name',
          trailing: core.name,
        ),
        CpuInfoItem(
          title: '[CPU ${cores.indexOf(core)}] Socket',
          trailing: core.socket.toString(),
        ),
        CpuInfoItem(
          title: '[CPU ${cores.indexOf(core)}] Vendor',
          trailing: core.vendor,
        ),
      ]);
    }
    deviceInfo.add(CpuInfoItem(
      title: 'Number of processors',
      trailing: cores.length.toString(),
      child: coreList,
    ));
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _deviceInfo = deviceInfo;
      });
    });
  }
}

class CpuInfoCell extends StatelessWidget {
  final CpuInfoItem cpuInfoItem;

  const CpuInfoCell({Key? key, required this.cpuInfoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cpuInfoItem.child == null) {
      return ListTile(
        title: Text(
          cpuInfoItem.title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 210),
          child: Text(
            cpuInfoItem.trailing,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        cpuInfoItem.title,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 210),
        child: Text(
          cpuInfoItem.trailing,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
      children: cpuInfoItem.child!
          .map((cpuInfo) => ColoredBox(
                color: Colors.grey.shade100,
                child: ListTile(
                  title: Text(
                    cpuInfo.title,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 210),
                    child: Text(
                      cpuInfo.trailing,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
