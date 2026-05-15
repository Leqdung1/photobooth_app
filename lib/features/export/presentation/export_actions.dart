import 'package:flutter/material.dart';

class ExportActions extends StatelessWidget {
  const ExportActions({
    super.key,
    required this.isExporting,
    required this.isPreviewing,
    required this.onExport,
    required this.onPreview,
    required this.onReset,
    required this.statusMessage,
  });

  final bool isExporting;
  final bool isPreviewing;
  final VoidCallback onExport;
  final VoidCallback onPreview;
  final VoidCallback onReset;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: isExporting || isPreviewing ? null : onExport,
              child: Text(isExporting ? 'Exporting...' : 'Export'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: isExporting || isPreviewing ? null : onPreview,
              child: Text(isPreviewing ? 'Đang tạo...' : 'Preview'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: isExporting || isPreviewing ? null : onReset,
              child: const Text('Reset'),
            ),
          ],
        ),
        if (statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            statusMessage!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
