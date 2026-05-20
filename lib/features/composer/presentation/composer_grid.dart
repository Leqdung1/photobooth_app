import 'package:flutter/material.dart';

import '../domain/frame_template.dart';
import '../domain/slot_assignment.dart';
import 'photo_frame_view.dart';

class ComposerGrid extends StatelessWidget {
  const ComposerGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onClearSlot,
    required this.template,
    required this.onTransformChanged,
    required this.columns,
    required this.aspectRatio,
  });

  final List<SlotAssignment> slots;
  final int selectedSlot;
  final ValueChanged<int> onSlotSelected;
  final ValueChanged<int> onClearSlot;
  final FrameTemplate template;
  final SlotTransformChanged onTransformChanged;
  final int columns;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return PhotoFrameView(
      slots: slots,
      template: template,
      columns: columns,
      aspectRatio: aspectRatio,
      selectedSlot: selectedSlot,
      onSlotSelected: onSlotSelected,
      onTransformChanged: onTransformChanged,
      onClearSlot: onClearSlot,
    );
  }
}
