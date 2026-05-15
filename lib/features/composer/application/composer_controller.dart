import 'package:flutter/foundation.dart';

import '../domain/frame_template.dart';
import '../domain/slot_assignment.dart';

class ComposerController extends ChangeNotifier {
  ComposerController()
      : _selectedTemplate = FrameTemplate.oneByTwo,
        _slots = _buildSlots(FrameTemplate.oneByTwo.slotCount);

  FrameTemplate _selectedTemplate;
  List<SlotAssignment> _slots;

  FrameTemplate get selectedTemplate => _selectedTemplate;
  List<SlotAssignment> get slots => List<SlotAssignment>.unmodifiable(_slots);

  static List<SlotAssignment> _buildSlots(int slotCount) {
    return List<SlotAssignment>.generate(
      slotCount,
      (index) => SlotAssignment(slotIndex: index + 1),
      growable: false,
    );
  }

  void setTemplate(FrameTemplate template) {
    if (_selectedTemplate.id == template.id) {
      return;
    }
    _selectedTemplate = template;
    _slots = _buildSlots(template.slotCount);
    notifyListeners();
  }

  void assign({required int slotIndex, required String assetPath}) {
    _slots = _slots
        .map(
          (slot) => slot.slotIndex == slotIndex
              ? slot.copyWith(assetPath: assetPath)
              : slot,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void clearSlot(int slotIndex) {
    _slots = _slots
        .map(
          (slot) => slot.slotIndex == slotIndex ? slot.copyWith(clear: true) : slot,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void resetAll() {
    _slots = _buildSlots(_selectedTemplate.slotCount);
    notifyListeners();
  }
}
