import 'package:flutter_kit/service/service_mixin.dart';
import 'package:vm_service/vm_service.dart';

class Property {
  final bool? isConst;
  final bool? isStatic;
  final bool? isFinal;
  final String? type;
  final String? name;

  String get propertyStr {
    StringBuffer val = StringBuffer();
    if (isStatic!) {
      val.write("static");
      val.write(' ');
    } else if (isConst!) {
      val.write("const");
      val.write(' ');
    } else {
      val.write('final');
      val.write(' ');
    }
    return "${val.toString()}  $type  $name";
  }

  Property(this.isConst, this.isStatic, this.isFinal, this.type, this.name);
}

class ClsModel {
  final List<Property>? properties;
  final List<String>? functions;

  ClsModel({this.properties, this.functions});
}

class MemoryService with VMServiceWrapper {
  List<ClassHeapStats> infoList = [];

  List<ClassHeapStats> allClasses = [];

  String vmInfo = "";

  String memoryUsage = "";

  void getInfo(Function completion) async {
    List results = await Future.wait([
      serviceWrapper.getClassHeapStats(),
      serviceWrapper.getMemoryUsage(),
      serviceWrapper.getVM()
    ]);
    _heapInfoList(results[0]);
    _memoryUsed(results[1]);
    _vmToInfo(results[2]);
    completion();
  }

  void getInstanceIds(
    String classId,
    int limit,
    Function(List<String?>) completion,
  ) async {
    InstanceSet instanceSet = await serviceWrapper.getInstances(classId, limit);
    List<String?> instanceIds =
        instanceSet.instances!.map((e) => e.id).toList();
    completion(instanceIds);
  }

  void getClassDetailInfo(
      String classId, Function(ClsModel?) completion) async {
    Class cls = await serviceWrapper.getObject(classId) as Class;
    ClsModel? clsModel;
    if (cls.fields != null && cls.fields!.isNotEmpty) {
      List<Property> properties = [];
      List<String> functions = [];
      cls.fields?.forEach((fieldRef) {
        Property property = Property(
          fieldRef.isConst,
          fieldRef.isStatic,
          fieldRef.isFinal,
          fieldRef.declaredType!.name,
          fieldRef.name,
        );
        properties.add(property);
      });
      for (var fucRef in cls.functions!) {
        String? code;
        Obj func = await serviceWrapper.getObject(fucRef.id!);
        if (func is Func) {
          code = func.code!.name;
          if (func.code!.name!.contains("[Stub]")) {
            continue;
          }
          code = code!.replaceAll('[Unoptimized] ', '');
          code = code.replaceAll('[Optimized] ', '');
          functions.add(code);
        }
      }
      clsModel = ClsModel(properties: properties, functions: functions);
    }
    completion(clsModel);
  }

  void _heapInfoList(List<ClassHeapStats> list) {
    allClasses = list;
    allClasses.sort((a, b) => b.accumulatedSize!.compareTo(a.accumulatedSize!));
    infoList = allClasses
        .where((element) => !element.classRef!.name!.startsWith("_"))
        .toList();
  }

  void _vmToInfo(VM vm) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("Pid:  ${vm.pid}");
    buffer.writeln("CPU:  ${vm.hostCPU}");
    buffer.writeln("Version:  ${vm.version}");
    vmInfo = buffer.toString();
  }

  void _memoryUsed(MemoryUsage usage) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("ExternalUsage:  ${byteToString(usage.externalUsage!)}");
    buffer.writeln("HeapCapacity:  ${byteToString(usage.heapCapacity!)}");
    buffer.writeln("HeapUsage:  ${byteToString(usage.heapUsage!)}");
    memoryUsage = buffer.toString();
  }

  void hidePrivateClasses(bool hide) {
    if (hide) {
      infoList = allClasses
          .where((element) => !element.classRef!.name!.startsWith("_"))
          .toList();
    } else {
      infoList = allClasses;
    }
  }

  void sort<T>(
    Comparable<T>? Function(ClassHeapStats d) getField,
    bool descending,
    void Function() completion,
  ) {
    sort(List list) {
      list.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return descending
            ? Comparable.compare(bValue!, aValue!)
            : Comparable.compare(aValue!, bValue!);
      });
    }

    sort(infoList);
    sort(allClasses);
    completion();
  }

  String byteToString(int size) {
    const int m = 1024 * 1024;
    const int k = 1024;
    String resultSize = "";
    if (size / m >= 1) {
      resultSize = "${(size / m).toStringAsFixed(1)} M";
    } else if (size / k >= 1) {
      resultSize = "${(size / k).toStringAsFixed(1)} K";
    } else {
      resultSize = "$size B";
    }
    return resultSize;
  }
}
