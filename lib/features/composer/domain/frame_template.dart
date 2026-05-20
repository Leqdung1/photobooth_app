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
    this.customLayout,
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

  /// Custom slot layout (normalized 0..1 coordinates) for stack/clip templates.
  final CustomLayoutDefinition? customLayout;

  /// Whether export should draw divider lines between grid cells.
  final bool drawGridLines;

  int get slotCount => rows * columns;

  bool get isPolaroid => kind == FrameTemplateKind.polaroid;
  bool get isCustom => kind == FrameTemplateKind.custom;

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

  /// Editorial 5-vertical stack layout (sample-like composition).
  static const editorialFiveVertical = FrameTemplate(
    id: 'editorial_5v',
    label: 'Editorial 5V',
    kind: FrameTemplateKind.custom,
    rows: 1,
    columns: 5,
    exportWidth: 1200,
    exportHeight: 1500,
    previewAspectRatio: 1200 / 1500,
    customLayout: CustomLayoutDefinition(
      dividerThicknessRatio: 0.006,
      slots: [
        // left top
        NormalizedRect(0.00, 0.00, 0.31, 0.53),
        // left bottom
        NormalizedRect(0.00, 0.53, 0.31, 1.00),
        // center tall
        NormalizedRect(0.31, 0.00, 0.66, 1.00),
        // right top
        NormalizedRect(0.66, 0.00, 1.00, 0.52),
        // right bottom
        NormalizedRect(0.66, 0.52, 1.00, 1.00),
      ],
    ),
    drawGridLines: false,
  );

  static const List<FrameTemplate> presets = [
    oneByTwo,
    twoByTwo,
    polaroidAuto,
    editorialFiveVertical,
  ];
}

enum FrameTemplateKind {
  grid,
  polaroid,
  custom,
}

class PolaroidBorder {
  const PolaroidBorder({required this.top, required this.side, required this.bottom});

  final int top;
  final int side;
  final int bottom;
}

class CustomLayoutDefinition {
  const CustomLayoutDefinition({
    required this.slots,
    this.dividerThicknessRatio = 0.006,
    this.outerPaddingRatio = 0.02,
  });

  final List<NormalizedRect> slots;
  final double dividerThicknessRatio;
  final double outerPaddingRatio;
}

class NormalizedRect {
  const NormalizedRect(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;
}
