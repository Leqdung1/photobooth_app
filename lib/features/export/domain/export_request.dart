import '../../composer/domain/frame_template.dart';

class ExportRequest {
  const ExportRequest({
    required this.slotPaths,
    required this.exportsDirectory,
    required this.rows,
    required this.columns,
    required this.template,
  });

  final List<String?> slotPaths;
  final String exportsDirectory;
  final int rows;
  final int columns;
  final FrameTemplate template;

  int get requiredSlots => rows * columns;

  bool get isReady => slotPaths.length == requiredSlots && slotPaths.every((path) => path != null);
}
