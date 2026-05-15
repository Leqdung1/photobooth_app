import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:photo_booth/features/export/application/export_service.dart';
import 'package:photo_booth/features/export/domain/export_request.dart';

void main() {
  test('export writes a collision-safe file when all slots are filled', () async {
    final tempRoot = await Directory.systemTemp.createTemp('photo_booth_test_');
    final inbox = Directory('${tempRoot.path}/inbox')..createSync(recursive: true);
    final exports = Directory('${tempRoot.path}/exports')..createSync(recursive: true);

    final paths = <String>[];
    for (var i = 0; i < 4; i++) {
      final image = img.Image(width: 64, height: 64);
      img.fill(image, color: img.ColorRgb8(50 * i, 30 * i, 20 * i));
      final path = '${inbox.path}/$i.jpg';
      File(path).writeAsBytesSync(img.encodeJpg(image));
      paths.add(path);
    }

    final service = ExportService();
    final result = await service.export(
      ExportRequest(
        slotPaths: paths,
        exportsDirectory: exports.path,
        rows: 2,
        columns: 2,
      ),
    );

    expect(result.success, isTrue);
    expect(result.filePath, isNotNull);
    expect(File(result.filePath!).existsSync(), isTrue);

    await tempRoot.delete(recursive: true);
  });

  test('export supports 2x4 template and rejects incomplete slots', () async {
    final tempRoot = await Directory.systemTemp.createTemp('photo_booth_test_');
    final inbox = Directory('${tempRoot.path}/inbox')..createSync(recursive: true);
    final exports = Directory('${tempRoot.path}/exports')..createSync(recursive: true);

    final paths = <String>[];
    for (var i = 0; i < 8; i++) {
      final image = img.Image(width: 64, height: 64);
      img.fill(image, color: img.ColorRgb8(20 * i, 10 * i, 5 * i));
      final path = '${inbox.path}/$i.jpg';
      File(path).writeAsBytesSync(img.encodeJpg(image));
      paths.add(path);
    }

    final service = ExportService();
    final success = await service.export(
      ExportRequest(
        slotPaths: paths,
        exportsDirectory: exports.path,
        rows: 4,
        columns: 2,
      ),
    );

    expect(success.success, isTrue);
    expect(success.filePath, isNotNull);
    expect(File(success.filePath!).existsSync(), isTrue);

    final incomplete = await service.export(
      ExportRequest(
        slotPaths: paths.take(7).cast<String?>().toList(growable: false),
        exportsDirectory: exports.path,
        rows: 4,
        columns: 2,
      ),
    );

    expect(incomplete.success, isFalse);
    expect(incomplete.error, 'Please fill all 8 slots before export.');

    await tempRoot.delete(recursive: true);
  });
}
