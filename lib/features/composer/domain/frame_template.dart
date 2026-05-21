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
    this.outerPaddingInsetsRatio,
    this.cellPaddingRatio,
    this.cellPaddingInsetsRatio,
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

  /// Grid-only: outer padding as fraction of canvas (uniform all sides).
  final double? outerPaddingRatio;

  /// Grid-only: outer padding per-side (fractions of canvas W/H). Overrides [outerPaddingRatio].
  final NormalizedInsets? outerPaddingInsetsRatio;

  /// Grid-only: inner padding inside each cell as fraction of cell size.
  final double? cellPaddingRatio;

  /// Grid-only: inner padding per-side (fractions of cell W/H). Overrides [cellPaddingRatio].
  final NormalizedInsets? cellPaddingInsetsRatio;

  /// Polaroid-only: exact border sizes in pixels.
  final PolaroidBorder? polaroidBorder;

  /// Custom slot layout (normalized 0..1 coordinates).
  final CustomLayoutDefinition? customLayout;

  /// Whether export should draw divider lines between grid cells.
  final bool drawGridLines;

  int get slotCount => rows * columns;

  bool get isPolaroid => kind == FrameTemplateKind.polaroid;
  bool get isCustom => kind == FrameTemplateKind.custom;

  // ─── 1×2 Polaroid-card layout ────────────────────────────────────────────
  // Requested adjustments:
  // - Divider between cards: 1px thin line
  // - Increase borders (make image smaller inside each card)
  //
  // Canvas: 1200 × 1940
  // Card padding (inside each card):
  //   left/right = 30px
  //   top        = 25px
  //   bottom     = 90px
  // Image (4:3) uses full inner width: 1200 - 2*30 = 1140px
  // Image height = 1140 * 3/4 = 855px
  // Card height  = 25 + 855 + 90 = 970px
  // 2 cards + 1px divider => total height = 970 + 1 + 970 = 1941 (we keep canvas 1940)
  // We'll shrink card heights slightly by 0.5px equivalent via normalization.
  static const oneByTwo = FrameTemplate(
    id: '1x2',
    label: '2 ảnh (dọc)',
    kind: FrameTemplateKind.custom,
    rows: 2,
    columns: 1,
    exportWidth: 1200,
    // +10px each side from previous:
    //   L/R: 60 -> 70px
    //   Top: 50 -> 60px
    //   Bottom: 150 -> 160px
    // Image = 1060×795 (4:3), card height = 60+795+160 = 1015
    // Canvas = 1015 + 1px divider + 1015 = 2031
    exportHeight: 2031,
    previewAspectRatio: 1200 / 2031,
    customLayout: CustomLayoutDefinition(
      outerPaddingRatio: 0,
      dividerThicknessRatio: 0, // divider handled by cardDividerPx
      showCardShadow: true,
      cardDividerPx: 1,
      // Image areas (normalized to canvas)
      slots: [
        // L/R=70px -> x=70..1130
        // Slot 1 image: y=60..855 (60 top, 160 bottom; image 795px)
        NormalizedRect(0.0583333, 0.02954, 0.9416667, 0.42100),
        // Slot 2 image: y=1076..1871 (1015 + 1 divider + 60 top)
        NormalizedRect(0.0583333, 0.52979, 0.9416667, 0.92122),
      ],
      // Card rects
      cardRects: [
        // Card 1: y=0..1015
        NormalizedRect(0.0, 0.0, 1.0, 0.49975),
        // Card 2: y=1016..2031 (starts after 1px divider)
        NormalizedRect(0.0, 0.50025, 1.0, 1.0),
      ],
    ),
    drawGridLines: false,
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
    outerPaddingRatio: 0.022,
    cellPaddingRatio: 0.025,
    drawGridLines: true,
  );

  static const fourByFour = FrameTemplate(
    id: '4x4',
    label: '16 ảnh (4x4)',
    kind: FrameTemplateKind.grid,
    rows: 4,
    columns: 4,
    exportWidth: 1200,
    exportHeight: 1800,
    previewAspectRatio: 2 / 3,
    outerPaddingRatio: 0.018,
    cellPaddingRatio: 0.012,
    drawGridLines: true,
  );

  static const oneByThree = FrameTemplate(
    id: '1x3',
    label: '3 ảnh dọc (3x4)',
    kind: FrameTemplateKind.grid,
    rows: 3,
    columns: 1,
    exportWidth: 1200,
    exportHeight: 1800,
    previewAspectRatio: 2 / 3,
    outerPaddingRatio: 0.022,
    cellPaddingRatio: 0.02,
    drawGridLines: true,
  );

  static const oneByFour = FrameTemplate(
    id: '1x4',
    label: '4 ảnh dọc (3x4)',
    kind: FrameTemplateKind.grid,
    rows: 4,
    columns: 1,
    exportWidth: 1200,
    exportHeight: 1800,
    previewAspectRatio: 2 / 3,
    outerPaddingRatio: 0.02,
    cellPaddingRatio: 0.018,
    drawGridLines: true,
  );

  /// Polaroid (auto): chooses portrait/landscape canvas from input image ratio.
  static const polaroidAuto = FrameTemplate(
    id: 'polaroid_auto',
    label: 'Polaroid (auto)',
    kind: FrameTemplateKind.polaroid,
    rows: 1,
    columns: 1,
    exportWidth: 1200,
    exportHeight: 1500,
    previewAspectRatio: 1200 / 1500,
    drawGridLines: false,
  );

  /// Editorial 5-vertical stack layout.
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
        NormalizedRect(0.00, 0.00, 0.31, 0.53),
        NormalizedRect(0.00, 0.53, 0.31, 1.00),
        NormalizedRect(0.31, 0.00, 0.66, 1.00),
        NormalizedRect(0.66, 0.00, 1.00, 0.52),
        NormalizedRect(0.66, 0.52, 1.00, 1.00),
      ],
    ),
    drawGridLines: false,
  );

  static const List<FrameTemplate> presets = [
    oneByTwo,
    oneByThree,
    oneByFour,
    twoByTwo,
    fourByFour,
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
    this.showCardShadow = false,
    this.cardRects = const [],
    this.cardDividerPx = 0,
  });

  final List<NormalizedRect> slots;
  final double dividerThicknessRatio;
  final double outerPaddingRatio;

  /// If true, draw polaroid-card backgrounds (white rect + shadow) for each [cardRects].
  final bool showCardShadow;

  /// Normalized card boundary rects (for polaroid-card rendering in preview).
  final List<NormalizedRect> cardRects;

  /// Divider thickness between first two cards (pixels). If 0, no divider.
  final int cardDividerPx;
}

class NormalizedInsets {
  const NormalizedInsets({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  const NormalizedInsets.symmetric({
    required double horizontal,
    required double top,
    required double bottom,
  })  : left = horizontal,
        right = horizontal,
        top = top,
        bottom = bottom;

  final double left;
  final double top;
  final double right;
  final double bottom;
}

class NormalizedRect {
  const NormalizedRect(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;
}
