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
    return Container(
      color: Colors.grey.shade100,
      child: assets.isEmpty
          ? const Center(child: Text('Inbox is empty'))
          : ListView.separated(
              itemCount: assets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final asset = assets[index];
                final selected = asset.id == selectedAssetId;
                return ListTile(
                  selected: selected,
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.file(
                      File(asset.thumbnailPath ?? asset.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(asset.path.split('\\').last),
                  subtitle: Text(asset.createdAt.toIso8601String()),
                  onTap: () => onAssetSelected(asset),
                );
              },
            ),
    );
  }
}
