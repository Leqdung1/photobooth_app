class SlotAssignment {
  const SlotAssignment({required this.slotIndex, this.assetPath});

  final int slotIndex;
  final String? assetPath;

  bool get isFilled => assetPath != null;

  SlotAssignment copyWith({String? assetPath, bool clear = false}) {
    return SlotAssignment(
      slotIndex: slotIndex,
      assetPath: clear ? null : (assetPath ?? this.assetPath),
    );
  }
}
