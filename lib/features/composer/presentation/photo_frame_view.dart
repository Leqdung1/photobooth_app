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
            final cellPadRatio = template.isPolaroid ? 0 : (template.cellPaddingRatio ?? 0);

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
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final divider = (w * layout.dividerThicknessRatio).clamp(1, 6).toDouble();
            final outerPad = (w * layout.outerPaddingRatio).clamp(0, w * 0.08).toDouble();

            return Stack(
              children: [
                for (var i = 0; i < layout.slots.length && i < slots.length; i++)
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
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(w, h),
                    painter: _FrameOverlayPainter(
                      layout: layout,
                      divider: divider,
                      outerPadding: outerPad,
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

class _SlotViewport extends StatefulWidget {
  const _SlotViewport({
    required this.bounds,
    required this.slot,
    required this.canvasW,
    required this.canvasH,
    required this.originX,
    required this.originY,
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
                            child: Image.file(
                              File(widget.slot.assetPath!),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
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

class _FrameOverlayPainter extends CustomPainter {
  const _FrameOverlayPainter({
    required this.layout,
    required this.divider,
    required this.outerPadding,
  });

  final CustomLayoutDefinition layout;
  final double divider;
  final double outerPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = divider
      ..style = PaintingStyle.stroke;

    final outer = Rect.fromLTWH(
      outerPadding,
      outerPadding,
      size.width - outerPadding * 2,
      size.height - outerPadding * 2,
    );
    canvas.drawRect(outer, paint);

    // Draw slot boundaries for visual frame lines.
    for (final s in layout.slots) {
      final r = Rect.fromLTWH(
        outerPadding + s.left * (size.width - outerPadding * 2),
        outerPadding + s.top * (size.height - outerPadding * 2),
        (s.right - s.left) * (size.width - outerPadding * 2),
        (s.bottom - s.top) * (size.height - outerPadding * 2),
      );
      canvas.drawRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FrameOverlayPainter oldDelegate) {
    return oldDelegate.divider != divider ||
        oldDelegate.layout != layout ||
        oldDelegate.outerPadding != outerPadding;
  }
}

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
