import 'package:flutter/foundation.dart';

import '../domain/slot_assignment.dart';

class ComposerController extends ChangeNotifier {
  ComposerController()
      : _slots = List<SlotAssignment>.generate(
          4,
          (index) => SlotAssignment(slotIndex: index + 1),
        );

  List<SlotAssignment> _slots;

  List<SlotAssignment> get slots => List<SlotAssignment>.unmodifiable(_slots);

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
    _slots = List<SlotAssignment>.generate(
      4,
      (index) => SlotAssignment(slotIndex: index + 1),
      growable: false,
    );
    notifyListeners();
  }
}
