class ExportRequest {
  const ExportRequest({required this.slotPaths, required this.exportsDirectory});

  final List<String?> slotPaths;
  final String exportsDirectory;

  bool get isReady => slotPaths.length == 4 && slotPaths.every((path) => path != null);
}
