import 'package:flutter_test/flutter_test.dart';

import 'package:photo_booth/features/composer/application/composer_controller.dart';
import 'package:photo_booth/features/composer/domain/frame_template.dart';

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

  test('setTemplate switches slot count and reset honors selected template', () {
    final controller = ComposerController();

    controller.assign(slotIndex: 1, assetPath: 'C:/tmp/1.jpg');
    controller.setTemplate(FrameTemplate.twoByFour);

    expect(controller.selectedTemplate.id, FrameTemplate.twoByFour.id);
    expect(controller.slots.length, 8);
    expect(controller.slots.every((slot) => slot.assetPath == null), isTrue);

    controller.assign(slotIndex: 8, assetPath: 'C:/tmp/8.jpg');
    expect(controller.slots[7].assetPath, 'C:/tmp/8.jpg');

    controller.resetAll();
    expect(controller.slots.length, 8);
    expect(controller.slots.every((slot) => slot.assetPath == null), isTrue);
  });
}
