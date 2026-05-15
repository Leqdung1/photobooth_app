import 'package:flutter_test/flutter_test.dart';

import 'package:photo_booth/features/composer/application/composer_controller.dart';

void main() {
  test('assign, clear, and reset keep 4 deterministic slots', () {
    final controller = ComposerController();

    expect(controller.slots.length, 4);
    expect(controller.slots.every((slot) => slot.assetPath == null), isTrue);

    controller.assign(slotIndex: 2, assetPath: 'C:/tmp/a.jpg');
    expect(controller.slots[1].assetPath, 'C:/tmp/a.jpg');

    controller.clearSlot(2);
    expect(controller.slots[1].assetPath, isNull);

    controller.assign(slotIndex: 1, assetPath: 'C:/tmp/1.jpg');
    controller.assign(slotIndex: 4, assetPath: 'C:/tmp/4.jpg');
    controller.resetAll();

    expect(controller.slots.every((slot) => slot.assetPath == null), isTrue);
  });
}
