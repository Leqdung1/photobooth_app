import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../composer/domain/frame_layout.dart';
import '../../composer/domain/frame_template.dart';
import '../domain/export_request.dart';

class ExportResult {
  const ExportResult({required this.success, this.filePath, this.error});

  final bool success;
  final String? filePath;
  final String? error;
}

class PreviewResult {
  const PreviewResult({required this.success, this.imageBytes, this.error});

  final bool success;
  final Uint8List? imageBytes;
  final String? error;
}

class ExportService {
  _RenderCache? _cache;

  Future<PreviewResult> buildPreview(ExportRequest request) async {
    final cacheKey = await _buildCacheKey(request);
    final cached = _cache;
    if (cached != null && cached.key == cacheKey && cached.previewJpegBytes != null) {
      return PreviewResult(success: true, imageBytes: cached.previewJpegBytes);
    }

    final rendered = await _render(request, includePng: true, includePreviewJpeg: true);
    if (rendered.error != null) {
      return PreviewResult(success: false, error: rendered.error);
    }

    _cache = _RenderCache(
      key: cacheKey,
      previewJpegBytes: rendered.previewJpegBytes,
      pngBytes: rendered.pngBytes,
    );

    return PreviewResult(success: true, imageBytes: rendered.previewJpegBytes);
  }

  Future<ExportResult> export(ExportRequest request) async {
    final cacheKey = await _buildCacheKey(request);

    Uint8List pngBytes;
    final cached = _cache;
    if (cached != null && cached.key == cacheKey && cached.pngBytes != null) {
      pngBytes = cached.pngBytes!;
    } else {
      final rendered = await _render(request, includePng: true, includePreviewJpeg: false);
      if (rendered.error != null || rendered.pngBytes == null) {
        return ExportResult(success: false, error: rendered.error ?? 'Render failed');
      }
      pngBytes = rendered.pngBytes!;
      _cache = _RenderCache(
        key: cacheKey,
        previewJpegBytes: rendered.previewJpegBytes,
        pngBytes: rendered.pngBytes,
      );
    }

    final outputDir = Directory(request.exportsDirectory);
    await outputDir.create(recursive: true);

    final outputPath = _buildOutputPath(request.exportsDirectory);
    final outFile = File(outputPath);
    await outFile.writeAsBytes(pngBytes, flush: true);

    return ExportResult(success: true, filePath: outputPath);
  }

  Future<String> _buildCacheKey(ExportRequest request) async {
    final parts = <String>[
      request.template.id,
      '${request.rows}x${request.columns}',
    ];

    for (final path in request.slotPaths) {
      if (path == null) {
        parts.add('null');
        continue;
      }
      final file = File(path);
      if (!await file.exists()) {
        parts.add('missing:$path');
        continue;
      }
      final stat = await file.stat();
      parts.add('$path|${stat.modified.millisecondsSinceEpoch}|${stat.size}');
    }

    return parts.join('||');
  }

  Future<_RenderResult> _render(
    ExportRequest request, {
    required bool includePng,
    required bool includePreviewJpeg,
  }) async {
    if (!request.isReady) {
      return _RenderResult(error: 'Please fill all ${request.requiredSlots} slots before preview.');
    }

    final sourceBytes = <Uint8List>[];
    for (final path in request.slotPaths) {
      final file = File(path!);
      if (!await file.exists()) {
        return _RenderResult(error: 'Missing source file: ${file.path}');
      }
      sourceBytes.add(await file.readAsBytes());
    }

    final input = _RenderInput(
      template: request.template,
      rows: request.rows,
      columns: request.columns,
      sourceBytes: sourceBytes,
      includePng: includePng,
      includePreviewJpeg: includePreviewJpeg,
    );

    return Isolate.run(() => _renderInIsolate(input));
  }

  static _RenderResult _renderInIsolate(_RenderInput input) {
    if (input.sourceBytes.isEmpty) {
      return const _RenderResult(error: 'No source images provided.');
    }

    final firstDecoded = img.decodeImage(input.sourceBytes.first);
    if (firstDecoded == null) {
      return const _RenderResult(error: 'Cannot decode first image.');
    }

    final resolved = _resolveTemplateRuntime(input.template, firstDecoded.width / firstDecoded.height);
    final canvas = img.Image(width: resolved.canvasWidth, height: resolved.canvasHeight);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    int originX;
    int originY;
    int gridW;
    int gridH;

    if (resolved.isPolaroid && resolved.polaroidBorder != null) {
      final b = resolved.polaroidBorder!;
      originX = b.side;
      originY = b.top;
      gridW = resolved.canvasWidth - b.side * 2;
      gridH = resolved.canvasHeight - b.top - b.bottom;
    } else {
      final outerPadX = (resolved.canvasWidth * (resolved.outerPaddingRatio ?? FrameLayout.outerPaddingRatio)).round();
      final outerPadY = (resolved.canvasHeight * (resolved.outerPaddingRatio ?? FrameLayout.outerPaddingRatio)).round();
      originX = outerPadX;
      originY = outerPadY;
      gridW = resolved.canvasWidth - outerPadX * 2;
      gridH = resolved.canvasHeight - outerPadY * 2;
    }

    final cellW = gridW ~/ input.columns;
    final cellH = gridH ~/ input.rows;

    for (var i = 0; i < input.sourceBytes.length; i++) {
      final decoded = img.decodeImage(input.sourceBytes[i]);
      if (decoded == null) {
        return _RenderResult(error: 'Cannot decode image at slot ${i + 1}.');
      }

      final col = i % input.columns;
      final row = i ~/ input.columns;
      final cellX = originX + col * cellW;
      final cellY = originY + row * cellH;

      final cellPad = resolved.cellPaddingRatio ?? FrameLayout.cellPaddingRatio;
      final padX = resolved.isPolaroid ? 0 : (cellW * cellPad).round();
      final padY = resolved.isPolaroid ? 0 : (cellH * cellPad).round();
      final innerW = cellW - padX * 2;
      final innerH = cellH - padY * 2;

      final fitted = _resizeContain(decoded, innerW, innerH);
      final dx = cellX + padX + (innerW - fitted.width) ~/ 2;
      final dy = cellY + padY + (innerH - fitted.height) ~/ 2;
      img.compositeImage(canvas, fitted, dstX: dx, dstY: dy);
    }

    if (resolved.drawGridLines) {
      _drawGridLines(canvas, input.rows, input.columns, originX, originY, cellW, cellH);
    }

    return _RenderResult(
      pngBytes: input.includePng ? Uint8List.fromList(img.encodePng(canvas)) : null,
      previewJpegBytes: input.includePreviewJpeg
          ? Uint8List.fromList(img.encodeJpg(canvas, quality: 82))
          : null,
    );
  }

  static _ResolvedTemplate _resolveTemplateRuntime(FrameTemplate template, double sourceAspectRatio) {
    if (template.id != 'polaroid_auto') {
      return _ResolvedTemplate(
        canvasWidth: template.exportWidth,
        canvasHeight: template.exportHeight,
        isPolaroid: template.isPolaroid,
        polaroidBorder: template.polaroidBorder == null
            ? null
            : _ResolvedPolaroidBorder(
                top: template.polaroidBorder!.top,
                side: template.polaroidBorder!.side,
                bottom: template.polaroidBorder!.bottom,
              ),
        outerPaddingRatio: template.outerPaddingRatio,
        cellPaddingRatio: template.cellPaddingRatio,
        drawGridLines: template.drawGridLines,
      );
    }

    final isLandscape = sourceAspectRatio >= 1.0;
    final canvasW = isLandscape ? 1600 : 1200;
    final canvasH = isLandscape ? 1200 : 1500;

    final sideTop = (math.min(canvasW, canvasH) * (1 / 12)).round();
    final bottom = (sideTop * 2.3).round();

    return _ResolvedTemplate(
      canvasWidth: canvasW,
      canvasHeight: canvasH,
      isPolaroid: true,
      polaroidBorder: _ResolvedPolaroidBorder(top: sideTop, side: sideTop, bottom: bottom),
      outerPaddingRatio: null,
      cellPaddingRatio: 0,
      drawGridLines: false,
    );
  }

  static void _drawGridLines(
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

  static img.Image _resizeContain(img.Image source, int maxWidth, int maxHeight) {
    final scale = math.min(maxWidth / source.width, maxHeight / source.height);
    final targetW = math.max(1, (source.width * scale).round());
    final targetH = math.max(1, (source.height * scale).round());
    return img.copyResize(source, width: targetW, height: targetH);
  }

  String _buildOutputPath(String exportsDirectory) {
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    var counter = 1;
    while (true) {
      final candidate = p.join(exportsDirectory, 'final_${stamp}_$counter.png');
      if (!File(candidate).existsSync()) {
        return candidate;
      }
      counter++;
    }
  }
}

class _RenderInput {
  const _RenderInput({
    required this.template,
    required this.rows,
    required this.columns,
    required this.sourceBytes,
    required this.includePng,
    required this.includePreviewJpeg,
  });

  final FrameTemplate template;
  final int rows;
  final int columns;
  final List<Uint8List> sourceBytes;
  final bool includePng;
  final bool includePreviewJpeg;
}

class _RenderResult {
  const _RenderResult({this.error, this.pngBytes, this.previewJpegBytes});

  final String? error;
  final Uint8List? pngBytes;
  final Uint8List? previewJpegBytes;
}

class _RenderCache {
  const _RenderCache({required this.key, this.previewJpegBytes, this.pngBytes});

  final String key;
  final Uint8List? previewJpegBytes;
  final Uint8List? pngBytes;
}

class _ResolvedTemplate {
  const _ResolvedTemplate({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.isPolaroid,
    required this.polaroidBorder,
    required this.outerPaddingRatio,
    required this.cellPaddingRatio,
    required this.drawGridLines,
  });

  final int canvasWidth;
  final int canvasHeight;
  final bool isPolaroid;
  final _ResolvedPolaroidBorder? polaroidBorder;
  final double? outerPaddingRatio;
  final double? cellPaddingRatio;
  final bool drawGridLines;
}

class _ResolvedPolaroidBorder {
  const _ResolvedPolaroidBorder({required this.top, required this.side, required this.bottom});

  final int top;
  final int side;
  final int bottom;
}
