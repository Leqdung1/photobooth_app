import 'package:flutter/material.dart';

import '../domain/frame_layout.dart';
import '../domain/slot_assignment.dart';
import 'framed_photo_slot.dart';

class PhotoFrameView extends StatelessWidget {
  const PhotoFrameView({
    super.key,
    required this.slots,
    required this.columns,
    this.selectedSlot,
    this.onSlotSelected,
    this.onClearSlot,
  });

  final List<SlotAssignment> slots;
  final int columns;
  final int? selectedSlot;
  final ValueChanged<int>? onSlotSelected;
  final ValueChanged<int>? onClearSlot;

  bool get _interactive => onSlotSelected != null;

  @override
  Widget build(BuildContext context) {
    final rows = (slots.length / columns).ceil();

    return AspectRatio(
      aspectRatio: FrameLayout.portraitAspect,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List<Widget>.generate(rows, (row) {
            final rowSlots = slots.skip(row * columns).take(columns).toList();
            return Expanded(
              child: Column(
                children: [
                  if (row > 0)
                    Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                  Expanded(
                    child: Row(
                      children: List<Widget>.generate(rowSlots.length, (col) {
                        final slot = rowSlots[col];
                        final isSelected = selectedSlot == slot.slotIndex;
                        return Expanded(
                          child: Row(
                            children: [
                              if (col > 0)
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                              Expanded(
                                child: FramedPhotoSlot(
                                  label: 'Slot ${slot.slotIndex}',
                                  assetPath: slot.assetPath,
                                  isSelected: isSelected && _interactive,
                                  onTap: _interactive ? () => onSlotSelected!(slot.slotIndex) : null,
                                  onClear: _interactive && slot.assetPath != null
                                      ? () => onClearSlot!(slot.slotIndex)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
