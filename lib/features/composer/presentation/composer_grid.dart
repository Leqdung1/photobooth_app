import 'package:flutter/material.dart';

import '../domain/slot_assignment.dart';
import 'photo_frame_view.dart';

class ComposerGrid extends StatelessWidget {
  const ComposerGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onClearSlot,
    required this.columns,
  });

  final List<SlotAssignment> slots;
  final int selectedSlot;
  final ValueChanged<int> onSlotSelected;
  final ValueChanged<int> onClearSlot;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return PhotoFrameView(
      slots: slots,
      columns: columns,
      selectedSlot: selectedSlot,
      onSlotSelected: onSlotSelected,
      onClearSlot: onClearSlot,
    );
  }
}
