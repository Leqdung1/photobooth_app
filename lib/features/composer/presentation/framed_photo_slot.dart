import 'dart:io';

import 'package:flutter/material.dart';

class FramedPhotoSlot extends StatelessWidget {
  const FramedPhotoSlot({
    super.key,
    required this.label,
    this.assetPath,
    this.isSelected = false,
    this.onTap,
    this.onClear,
  });

  final String label;
  final String? assetPath;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: assetPath == null
                  ? Text(
                      label,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    )
                  : Image.file(
                      File(assetPath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
            ),
            if (assetPath != null && onClear != null)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
