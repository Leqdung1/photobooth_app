class FrameTemplate {
  const FrameTemplate({
    required this.id,
    required this.label,
    required this.kind,
    required this.rows,
    required this.columns,
    required this.exportWidth,
    required this.exportHeight,
    required this.previewAspectRatio,
    this.outerPaddingRatio,
    this.cellPaddingRatio,
    this.polaroidBorder,
    this.drawGridLines = true,
  });

  final String id;
  final String label;
  final FrameTemplateKind kind;
  final int rows;
  final int columns;

  /// Export canvas size (pixels).
  final int exportWidth;
  final int exportHeight;

  /// Aspect ratio used for on-screen preview.
  final double previewAspectRatio;

  /// Grid-only: outer padding as fraction of canvas.
  final double? outerPaddingRatio;

  /// Grid-only: inner padding inside each cell as fraction of cell size.
  final double? cellPaddingRatio;

  /// Polaroid-only: exact border sizes in pixels.
  final PolaroidBorder? polaroidBorder;

  /// Whether export should draw divider lines between grid cells.
  final bool drawGridLines;

  int get slotCount => rows * columns;

  bool get isPolaroid => kind == FrameTemplateKind.polaroid;

  static const oneByTwo = FrameTemplate(
    id: '1x2',
    label: '2 ảnh (dọc)',
    kind: FrameTemplateKind.grid,
    rows: 2,
    columns: 1,
    exportWidth: 1200,
    exportHeight: 1800,
    previewAspectRatio: 2 / 3,
    outerPaddingRatio: 0.05,
    cellPaddingRatio: 0.14,
    drawGridLines: true,
  );

  static const twoByTwo = FrameTemplate(
    id: '2x2',
    label: '4 ảnh (2x2)',
    kind: FrameTemplateKind.grid,
    rows: 2,
    columns: 2,
    exportWidth: 1200,
    exportHeight: 1800,
    previewAspectRatio: 2 / 3,
    outerPaddingRatio: 0.05,
    cellPaddingRatio: 0.14,
    drawGridLines: true,
  );


  /// Polaroid (auto): chooses portrait/landscape canvas from input image ratio.
  /// Border rule: top == left == right, bottom is larger.
  static const polaroidAuto = FrameTemplate(
    id: 'polaroid_auto',
    label: 'Polaroid (auto)',
    kind: FrameTemplateKind.polaroid,
    rows: 1,
    columns: 1,
    // Placeholder values for preview; export dimensions are decided at runtime.
    exportWidth: 1200,
    exportHeight: 1500,
    previewAspectRatio: 1200 / 1500,
    drawGridLines: false,
  );

  static const List<FrameTemplate> presets = [
    oneByTwo,
    twoByTwo,
    polaroidAuto,
  ];
}

enum FrameTemplateKind {
  grid,
  polaroid,
}

class PolaroidBorder {
  const PolaroidBorder({required this.top, required this.side, required this.bottom});

  final int top;
  final int side;
  final int bottom;
}
