import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/slot_assignment.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.slots});

  final List<SlotAssignment> slots;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: slots
            .map(
              (slot) => Container(
                margin: const EdgeInsets.all(2),
                color: Colors.grey.shade300,
                child: slot.assetPath == null
                    ? Center(child: Text('Preview ${slot.slotIndex}'))
                    : Image.file(
                        File(slot.assetPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
