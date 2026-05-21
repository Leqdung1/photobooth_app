import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/frame_template.dart';
import '../domain/slot_assignment.dart';

typedef SlotTransformChanged = void Function({
  required int slotIndex,
  required double scale,
  required double offsetX,
  required double offsetY,
});

class PhotoFrameView extends StatelessWidget {
  const PhotoFrameView({
    super.key,
    required this.slots,
    required this.template,
    required this.columns,
    required this.aspectRatio,
    this.selectedSlot,
    this.onSlotSelected,
    this.onTransformChanged,
    this.onClearSlot,
  });

  final List<SlotAssignment> slots;
  final FrameTemplate template;
  final int columns;
  final double aspectRatio;
  final int? selectedSlot;
  final ValueChanged<int>? onSlotSelected;
  final SlotTransformChanged? onTransformChanged;
  final ValueChanged<int>? onClearSlot;

  bool get _interactive => onSlotSelected != null;

  @override
  Widget build(BuildContext context) {
    if (template.isCustom && template.customLayout != null) {
      return _CustomTemplateView(
        template: template,
        slots: slots,
        aspectRatio: aspectRatio,
        selectedSlot: selectedSlot,
        onSlotSelected: onSlotSelected,
        onTransformChanged: onTransformChanged,
        onClearSlot: onClearSlot,
      );
    }

    return _GridTemplateView(
      template: template,
      slots: slots,
      columns: columns,
      aspectRatio: aspectRatio,
      selectedSlot: selectedSlot,
      onSlotSelected: onSlotSelected,
      onTransformChanged: onTransformChanged,
      onClearSlot: onClearSlot,
      interactive: _interactive,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid layout
// ─────────────────────────────────────────────────────────────────────────────

class _GridTemplateView extends StatelessWidget {
  const _GridTemplateView({
    required this.template,
    required this.slots,
    required this.columns,
    required this.aspectRatio,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onTransformChanged,
    required this.onClearSlot,
    required this.interactive,
  });

  final FrameTemplate template;
  final List<SlotAssignment> slots;
  final int columns;
  final double aspectRatio;
  final int? selectedSlot;
  final ValueChanged<int>? onSlotSelected;
  final SlotTransformChanged? onTransformChanged;
  final ValueChanged<int>? onClearSlot;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final rows = (slots.length / columns).ceil();

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final outerRatio = template.outerPaddingRatio ?? 0;
            final outerPadX = w * outerRatio;
            final outerPadY = h * outerRatio;
            final contentW = w - outerPadX * 2;
            final contentH = h - outerPadY * 2;

            final cellW = contentW / columns;
            final cellH = contentH / rows;
            final cellPadRatio = template.isPolaroid ? 0.0 : (template.cellPaddingRatio ?? 0.0);

            final slotsWidgets = <Widget>[];
            for (var i = 0; i < slots.length; i++) {
              final col = i % columns;
              final row = i ~/ columns;
              final slot = slots[i];

              final cellX = outerPadX + col * cellW;
              final cellY = outerPadY + row * cellH;
              final padX = cellW * cellPadRatio;
              final padY = cellH * cellPadRatio;

              final left = (cellX + padX) / w;
              final top = (cellY + padY) / h;
              final right = (cellX + cellW - padX) / w;
              final bottom = (cellY + cellH - padY) / h;

              slotsWidgets.add(
                _SlotViewport(
                  bounds: NormalizedRect(left, top, right, bottom),
                  slot: slot,
                  canvasW: w,
                  canvasH: h,
                  originX: 0,
                  originY: 0,
                  isSelected: selectedSlot == slot.slotIndex,
                  onSlotSelected: onSlotSelected,
                  onTransformChanged: onTransformChanged,
                  onClearSlot: onClearSlot,
                ),
              );
            }

            return Stack(
              children: [
                ...slotsWidgets,
                if (template.drawGridLines)
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(w, h),
                      painter: _GridOverlayPainter(
                        rows: rows,
                        columns: columns,
                        outerPadX: outerPadX,
                        outerPadY: outerPadY,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom layout (including polaroid-card style for 1×2)
// ─────────────────────────────────────────────────────────────────────────────

class _CustomTemplateView extends StatelessWidget {
  const _CustomTemplateView({
    required this.template,
    required this.slots,
    required this.aspectRatio,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onTransformChanged,
    required this.onClearSlot,
  });

  final FrameTemplate template;
  final List<SlotAssignment> slots;
  final double aspectRatio;
  final int? selectedSlot;
  final ValueChanged<int>? onSlotSelected;
  final SlotTransformChanged? onTransformChanged;
  final ValueChanged<int>? onClearSlot;

  @override
  Widget build(BuildContext context) {
    final layout = template.customLayout!;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        // Light grey background so the white cards pop
        color: const Color(0xFFF0F0F0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final outerPad = (w * layout.outerPaddingRatio).clamp(0.0, w * 0.08);

            final layers = <Widget>[];

            // 1. Draw polaroid card backgrounds (white rect + shadow + border)
            if (layout.showCardShadow && layout.cardRects.isNotEmpty) {
              for (final card in layout.cardRects) {
                final cardLeft = card.left * w;
                final cardTop = card.top * h;
                final cardW = (card.right - card.left) * w;
                final cardH = (card.bottom - card.top) * h;
                layers.add(
                  Positioned(
                    left: cardLeft,
                    top: cardTop,
                    width: cardW,
                    height: cardH,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }

            // 2. Draw photo slots
            for (var i = 0; i < layout.slots.length && i < slots.length; i++) {
              layers.add(
                _SlotViewport(
                  bounds: layout.slots[i],
                  slot: slots[i],
                  canvasW: w - outerPad * 2,
                  canvasH: h - outerPad * 2,
                  originX: outerPad,
                  originY: outerPad,
                  isSelected: selectedSlot == slots[i].slotIndex,
                  onSlotSelected: onSlotSelected,
                  onTransformChanged: onTransformChanged,
                  onClearSlot: onClearSlot,
                ),
              );
            }

            // 3. Grey divider between the two cards
            if (layout.showCardShadow && layout.cardRects.length >= 2) {
              final card1Bottom = layout.cardRects[0].bottom * h;
              final dividerH = (layout.cardDividerPx > 0 ? layout.cardDividerPx.toDouble() : 1.0).clamp(1.0, 6.0);
              layers.add(
                Positioned(
                  left: 0,
                  top: card1Bottom,
                  width: w,
                  height: dividerH,
                  child: Container(color: const Color(0xFFDDDDDD)),
                ),
              );
            }

            return Stack(children: layers);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot viewport (shared between grid and custom)
// ─────────────────────────────────────────────────────────────────────────────

class _SlotViewport extends StatefulWidget {
  const _SlotViewport({
    required this.bounds,
    required this.slot,
    required this.canvasW,
    required this.canvasH,
    required this.originX,
    required this.originY,
    this.quarterTurns = 0,
    required this.isSelected,
    required this.onSlotSelected,
    required this.onTransformChanged,
    required this.onClearSlot,
  });

  final NormalizedRect bounds;
  final SlotAssignment slot;
  final double canvasW;
  final double canvasH;
  final double originX;
  final double originY;
  final int quarterTurns;
  final bool isSelected;
  final ValueChanged<int>? onSlotSelected;
  final SlotTransformChanged? onTransformChanged;
  final ValueChanged<int>? onClearSlot;

  @override
  State<_SlotViewport> createState() => _SlotViewportState();
}

class _SlotViewportState extends State<_SlotViewport> {
  double _startScale = 1;
  double _startOffsetX = 0;
  double _startOffsetY = 0;

  @override
  void didUpdateWidget(covariant _SlotViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startScale = widget.slot.scale;
    _startOffsetX = widget.slot.offsetX;
    _startOffsetY = widget.slot.offsetY;
  }

  @override
  Widget build(BuildContext context) {
    final rect = Rect.fromLTWH(
      widget.originX + widget.bounds.left * widget.canvasW,
      widget.originY + widget.bounds.top * widget.canvasH,
      (widget.bounds.right - widget.bounds.left) * widget.canvasW,
      (widget.bounds.bottom - widget.bounds.top) * widget.canvasH,
    );

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        onTap: widget.onSlotSelected == null ? null : () => widget.onSlotSelected!(widget.slot.slotIndex),
        onScaleStart: (_) {
          _startScale = widget.slot.scale;
          _startOffsetX = widget.slot.offsetX;
          _startOffsetY = widget.slot.offsetY;
        },
        onScaleUpdate: (details) {
          if (widget.onTransformChanged == null || widget.slot.assetPath == null) return;
          final nextScale = (_startScale * details.scale).clamp(0.6, 5.0);
          widget.onTransformChanged!(
            slotIndex: widget.slot.slotIndex,
            scale: nextScale,
            offsetX: _startOffsetX + details.focalPointDelta.dx,
            offsetY: _startOffsetY + details.focalPointDelta.dy,
          );
        },
        child: ClipRect(
          child: Container(
            decoration: BoxDecoration(
              border: widget.isSelected ? Border.all(color: Colors.blueAccent, width: 2) : null,
            ),
            child: widget.slot.assetPath == null
                ? Center(
                    child: Text('Slot ${widget.slot.slotIndex}', style: TextStyle(color: Colors.grey.shade500)),
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(widget.slot.offsetX, widget.slot.offsetY),
                          child: Transform.scale(
                            scale: widget.slot.scale,
                            child: RotatedBox(
                              quarterTurns: widget.quarterTurns % 4,
                              child: Image.file(
                                File(widget.slot.assetPath!),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.onClearSlot != null)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Material(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => widget.onClearSlot!(widget.slot.slotIndex),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _GridOverlayPainter extends CustomPainter {
  const _GridOverlayPainter({
    required this.rows,
    required this.columns,
    required this.outerPadX,
    required this.outerPadY,
  });

  final int rows;
  final int columns;
  final double outerPadX;
  final double outerPadY;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final contentW = size.width - outerPadX * 2;
    final contentH = size.height - outerPadY * 2;
    final cellW = contentW / columns;
    final cellH = contentH / rows;

    for (var row = 1; row < rows; row++) {
      final y = outerPadY + row * cellH;
      canvas.drawLine(Offset(outerPadX, y), Offset(outerPadX + contentW, y), paint);
    }

    for (var col = 1; col < columns; col++) {
      final x = outerPadX + col * cellW;
      canvas.drawLine(Offset(x, outerPadY), Offset(x, outerPadY + contentH), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridOverlayPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.outerPadX != outerPadX ||
        oldDelegate.outerPadY != outerPadY;
  }
}
