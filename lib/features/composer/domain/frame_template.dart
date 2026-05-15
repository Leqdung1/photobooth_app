class FrameTemplate {
  const FrameTemplate({
    required this.id,
    required this.label,
    required this.rows,
    required this.columns,
  });

  final String id;
  final String label;
  final int rows;
  final int columns;

  int get slotCount => rows * columns;

  static const oneByTwo = FrameTemplate(
    id: '1x2',
    label: '2 ảnh (dọc)',
    rows: 2,
    columns: 1,
  );

  static const twoByTwo = FrameTemplate(
    id: '2x2',
    label: '4 ảnh (2x2)',
    rows: 2,
    columns: 2,
  );

  static const List<FrameTemplate> presets = [oneByTwo, twoByTwo];
}
