import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/photo_asset.dart';

class GalleryPanel extends StatelessWidget {
  const GalleryPanel({
    super.key,
    required this.assets,
    required this.selectedAssetId,
    required this.onAssetSelected,
  });

  final List<PhotoAsset> assets;
  final String? selectedAssetId;
  final ValueChanged<PhotoAsset> onAssetSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: ColoredBox(
        color: const Color(0xFF121E3B),
        child: assets.isEmpty
            ? const Center(
                child: Text(
                  'Chưa có ảnh trong thư mục',
                  style: TextStyle(color: Color(0xFFB7C8EE)),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                primary: false,
                itemCount: assets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final selected = asset.id == selectedAssetId;
                  final fileName = asset.path.split(Platform.pathSeparator).last;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onAssetSelected(asset),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF2A3D72)
                              : const Color(0xFF1D2B51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: Image.file(
                                File(asset.thumbnailPath ?? asset.path),
                                key: ValueKey(asset.thumbnailPath ?? asset.path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                              child: Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFE3ECFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                              child: Text(
                                asset.createdAt.toIso8601String(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFA9BDE8),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
