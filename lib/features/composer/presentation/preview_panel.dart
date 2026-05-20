import 'package:flutter/material.dart';

import '../domain/frame_layout.dart';
import '../domain/frame_template.dart';
import '../domain/slot_assignment.dart';
import 'photo_frame_view.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.slots, required this.columns});

  final List<SlotAssignment> slots;
  final int columns;

  @override
  Widget build(BuildContext context) {
    // Legacy panel (not wired to selected template) – keep portrait aspect.
    return PhotoFrameView(
      slots: slots,
      template: FrameTemplate.oneByTwo,
      columns: columns,
      aspectRatio: FrameLayout.portraitAspect,
    );
  }
}
