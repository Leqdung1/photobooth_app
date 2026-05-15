import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../domain/export_request.dart';

class ExportResult {
  const ExportResult({required this.success, this.filePath, this.error});

  final bool success;
  final String? filePath;
  final String? error;
}

class ExportService {
  static const canvasSize = 1600;

  Future<ExportResult> export(ExportRequest request) async {
    if (!request.isReady) {
      return const ExportResult(success: false, error: 'Please fill all 4 slots before export.');
    }

    final outputDir = Directory(request.exportsDirectory);
    await outputDir.create(recursive: true);

    final canvas = img.Image(width: canvasSize, height: canvasSize);
    const cell = canvasSize ~/ 2;

    for (var i = 0; i < request.slotPaths.length; i++) {
      final file = File(request.slotPaths[i]!);
      if (!await file.exists()) {
        return ExportResult(success: false, error: 'Missing source file: ${file.path}');
      }
      final decoded = img.decodeImage(await file.readAsBytes());
      if (decoded == null) {
        return ExportResult(success: false, error: 'Cannot decode image: ${file.path}');
      }
      final resized = img.copyResizeCropSquare(decoded, size: cell);
      final dx = (i % 2) * cell;
      final dy = (i ~/ 2) * cell;
      img.compositeImage(canvas, resized, dstX: dx, dstY: dy);
    }

    final outputPath = _buildOutputPath(request.exportsDirectory);
    final outFile = File(outputPath);
    await outFile.writeAsBytes(img.encodeJpg(canvas, quality: 92));

    return ExportResult(success: true, filePath: outputPath);
  }

  String _buildOutputPath(String exportsDirectory) {
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    var counter = 1;
    while (true) {
      final candidate = p.join(exportsDirectory, 'final_$stamp_$counter.jpg');
      if (!File(candidate).existsSync()) {
        return candidate;
      }
      counter++;
    }
  }
}
