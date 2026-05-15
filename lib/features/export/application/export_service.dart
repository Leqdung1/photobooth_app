import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import '../../composer/domain/frame_layout.dart';
import '../domain/export_request.dart';

class ExportResult {
  const ExportResult({required this.success, this.filePath, this.error});

  final bool success;
  final String? filePath;
  final String? error;
}

class ExportService {
  Future<ExportResult> export(ExportRequest request) async {
    if (!request.isReady) {
      return ExportResult(
        success: false,
        error: 'Please fill all ${request.requiredSlots} slots before export.',
      );
    }

    final outputDir = Directory(request.exportsDirectory);
    await outputDir.create(recursive: true);

    final canvas = img.Image(width: FrameLayout.exportWidth, height: FrameLayout.exportHeight);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    final outerPadX = (FrameLayout.exportWidth * FrameLayout.outerPaddingRatio).round();
    final outerPadY = (FrameLayout.exportHeight * FrameLayout.outerPaddingRatio).round();
    final gridW = FrameLayout.exportWidth - outerPadX * 2;
    final gridH = FrameLayout.exportHeight - outerPadY * 2;
    final cellW = gridW ~/ request.columns;
    final cellH = gridH ~/ request.rows;

    for (var i = 0; i < request.slotPaths.length; i++) {
      final file = File(request.slotPaths[i]!);
      if (!await file.exists()) {
        return ExportResult(success: false, error: 'Missing source file: ${file.path}');
      }
      final decoded = img.decodeImage(await file.readAsBytes());
      if (decoded == null) {
        return ExportResult(success: false, error: 'Cannot decode image: ${file.path}');
      }

      final col = i % request.columns;
      final row = i ~/ request.columns;
      final cellX = outerPadX + col * cellW;
      final cellY = outerPadY + row * cellH;

      final padX = (cellW * FrameLayout.cellPaddingRatio).round();
      final padY = (cellH * FrameLayout.cellPaddingRatio).round();
      final innerW = cellW - padX * 2;
      final innerH = cellH - padY * 2;

      final fitted = _resizeContain(decoded, innerW, innerH);
      final dx = cellX + padX + (innerW - fitted.width) ~/ 2;
      final dy = cellY + padY + (innerH - fitted.height) ~/ 2;
      img.compositeImage(canvas, fitted, dstX: dx, dstY: dy);
    }

    _drawGridLines(canvas, request.rows, request.columns, outerPadX, outerPadY, cellW, cellH);

    final outputPath = _buildOutputPath(request.exportsDirectory);
    final outFile = File(outputPath);
    await outFile.writeAsBytes(img.encodeJpg(canvas, quality: 92));

    return ExportResult(success: true, filePath: outputPath);
  }

  void _drawGridLines(
    img.Image canvas,
    int rows,
    int columns,
    int originX,
    int originY,
    int cellW,
    int cellH,
  ) {
    final lineColor = img.ColorRgb8(220, 220, 220);

    for (var row = 1; row < rows; row++) {
      final y = originY + row * cellH;
      for (var x = originX; x < originX + cellW * columns; x++) {
        canvas.setPixel(x, y, lineColor);
      }
    }

    for (var col = 1; col < columns; col++) {
      final x = originX + col * cellW;
      for (var y = originY; y < originY + cellH * rows; y++) {
        canvas.setPixel(x, y, lineColor);
      }
    }
  }

  img.Image _resizeContain(img.Image source, int maxWidth, int maxHeight) {
    final scale = math.min(maxWidth / source.width, maxHeight / source.height);
    final targetW = math.max(1, (source.width * scale).round());
    final targetH = math.max(1, (source.height * scale).round());
    return img.copyResize(source, width: targetW, height: targetH);
  }

  String _buildOutputPath(String exportsDirectory) {
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    var counter = 1;
    while (true) {
      final candidate = p.join(exportsDirectory, 'final_${stamp}_$counter.jpg');
      if (!File(candidate).existsSync()) {
        return candidate;
      }
      counter++;
    }
  }
}
