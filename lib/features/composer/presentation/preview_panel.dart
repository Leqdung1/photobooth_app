import 'package:flutter/material.dart';

import '../domain/slot_assignment.dart';
import 'photo_frame_view.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.slots, required this.columns});

  final List<SlotAssignment> slots;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return PhotoFrameView(slots: slots, columns: columns);
  }
}
