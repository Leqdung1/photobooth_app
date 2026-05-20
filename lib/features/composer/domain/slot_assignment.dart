class SlotAssignment {
  const SlotAssignment({
    required this.slotIndex,
    this.assetPath,
    this.scale = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final int slotIndex;
  final String? assetPath;
  final double scale;
  final double offsetX;
  final double offsetY;

  bool get isFilled => assetPath != null;

  SlotAssignment copyWith({
    String? assetPath,
    bool clear = false,
    double? scale,
    double? offsetX,
    double? offsetY,
    bool resetTransform = false,
  }) {
    return SlotAssignment(
      slotIndex: slotIndex,
      assetPath: clear ? null : (assetPath ?? this.assetPath),
      scale: resetTransform ? 1 : (scale ?? this.scale),
      offsetX: resetTransform ? 0 : (offsetX ?? this.offsetX),
      offsetY: resetTransform ? 0 : (offsetY ?? this.offsetY),
    );
  }
}
