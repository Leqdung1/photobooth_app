import '../../composer/domain/frame_template.dart';

class ExportRequest {
  const ExportRequest({
    required this.slots,
    required this.exportsDirectory,
    required this.rows,
    required this.columns,
    required this.template,
  });

  final List<ExportSlot> slots;
  final String exportsDirectory;
  final int rows;
  final int columns;
  final FrameTemplate template;

  List<String?> get slotPaths => slots.map((slot) => slot.assetPath).toList(growable: false);

  int get requiredSlots => rows * columns;

  bool get isReady => slots.length == requiredSlots && slots.every((slot) => slot.assetPath != null);
}

class ExportSlot {
  const ExportSlot({
    required this.assetPath,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  final String? assetPath;
  final double scale;
  final double offsetX;
  final double offsetY;
}
