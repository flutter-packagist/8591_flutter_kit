class CpuInfoItem {
  final String title;
  final String trailing;
  final List<CpuInfoItem>? child;

  CpuInfoItem({required this.title, required this.trailing, this.child});
}
