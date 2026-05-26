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
        // Reduced image size by 10% (keep 4:3).
        // Top margin reduced by 20px; lower slot also moved up 20px from divider.
        // New window per card: x=123..1077, y=79.75..795.25
        NormalizedRect(123 / 1200, 79.75 / 2031, 1077 / 1200, 795.25 / 2031),
        // Slot 2 image: y=1095.75..1811.25
        NormalizedRect(123 / 1200, 1095.75 / 2031, 1077 / 1200, 1811.25 / 2031),
      ],
      // Card rects
      cardRects: [
        // Card 1: y=0..1015
        NormalizedRect(0, 0, 1, 1015 / 2031),
        // Card 2: y=1016..2031 (starts after 1px divider)
        NormalizedRect(0, 1016 / 2031, 1, 1),
      ],
    ),
    drawGridLines: false,
  );

  static const twoByTwo = FrameTemplate(
    id: '2x2',
    label: '8 ảnh (2x4)',
    kind: FrameTemplateKind.grid,
    rows: 4,
    columns: 2,
    exportWidth: 1200,
    exportHeight: 1800,
    previewAspectRatio: 2 / 3,
    outerPaddingRatio: 0.022,
    // Increase inner spacing so photos are farther from center divider.
    cellPaddingRatio: 0.06,
    drawGridLines: true,
  );

  /// Two landscape photos stacked vertically with equal mat on all sides.
  /// (Matches: 2 photos, horizontal/landscape, thick even white border, thin grey divider)
  static const twoLandscapeMatted = FrameTemplate(
    id: '2_landscape_mat',
    label: 'towwo image ngang',
    kind: FrameTemplateKind.custom,
    rows: 2,
    columns: 1,
    exportWidth: 1200,
    // Updated per request:
    // - Size reduced 30% (keep 4:3)
    // - Shift right by +20px
    // - Left border increased by +20px
    // - Move both images 15px closer to center divider
    // Divider: 1px
    // New slot size = 676x507 (4:3) (+5% from previous)
    // Card height = 870, Canvas = 870 + 1 + 870 = 1741
    exportHeight: 1741,
    previewAspectRatio: 1200 / 1741,
    customLayout: CustomLayoutDefinition(
      outerPaddingRatio: 0,
      dividerThicknessRatio: 0,
      showCardShadow: true,
      cardDividerPx: 1,
      // Keep image content horizontal (no rotation).
      slotQuarterTurns: [0, 0],
      slots: [
        // Card 1: x=342..1018, y=300..807
        NormalizedRect(342 / 1200, 300 / 1741, 1018 / 1200, 807 / 1741),
        // Card 2: x=342..1018, y=934..1441
        NormalizedRect(342 / 1200, 934 / 1741, 1018 / 1200, 1441 / 1741),
      ],
      cardRects: [
        // Card 1: y=0..870
        NormalizedRect(0, 0, 1, 870 / 1741),
        // Card 2: y=871..1741
        NormalizedRect(0, 871 / 1741, 1, 1),
      ],
    ),
    drawGridLines: false,
  );

  /// Same as `towwo image ngang` but rotate image content 90° clockwise.
  static const twoImageDoc = FrameTemplate(
    id: '2_image_doc',
    label: 'two image dọc',
    kind: FrameTemplateKind.custom,
    rows: 2,
    columns: 1,
    exportWidth: 1200,
    exportHeight: 1741,
    previewAspectRatio: 1200 / 1741,
    customLayout: CustomLayoutDefinition(
      outerPaddingRatio: 0,
      dividerThicknessRatio: 0,
      showCardShadow: true,
      cardDividerPx: 1,
      slotQuarterTurns: [1, 1],
      slots: [
        NormalizedRect(342 / 1200, 300 / 1741, 1018 / 1200, 807 / 1741),
        NormalizedRect(342 / 1200, 934 / 1741, 1018 / 1200, 1441 / 1741),
      ],
      cardRects: [
        NormalizedRect(0, 0, 1, 870 / 1741),
        NormalizedRect(0, 871 / 1741, 1, 1),
      ],
    ),
    drawGridLines: false,
  );

  static const List<FrameTemplate> presets = [
    oneByTwo,
    twoLandscapeMatted,
    twoImageDoc,
    twoByTwo,
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
    this.slotQuarterTurns = const [],
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

  /// Optional per-slot 90° rotation steps (clockwise). Length should match [slots].
  /// Example: 1 = 90° clockwise, 2 = 180°, 3 = 270°.
  final List<int> slotQuarterTurns;
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
