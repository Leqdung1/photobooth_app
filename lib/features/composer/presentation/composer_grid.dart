import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/slot_assignment.dart';

class ComposerGrid extends StatelessWidget {
  const ComposerGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onClearSlot,
  });

  final List<SlotAssignment> slots;
  final int selectedSlot;
  final ValueChanged<int> onSlotSelected;
  final ValueChanged<int> onClearSlot;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot == slot.slotIndex;
        return InkWell(
          onTap: () => onSlotSelected(slot.slotIndex),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: slot.assetPath == null
                      ? Center(child: Text('Slot ${slot.slotIndex}'))
                      : Image.file(
                          File(slot.assetPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                ),
                if (slot.assetPath != null)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: IconButton(
                      iconSize: 16,
                      onPressed: () => onClearSlot(slot.slotIndex),
                      icon: const Icon(Icons.close),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
