import 'package:flutter/material.dart';

class ExportActions extends StatelessWidget {
  const ExportActions({
    super.key,
    required this.isExporting,
    required this.isPreviewing,
    required this.printAfterExport,
    required this.autoTransferToPhone,
    required this.onPrintAfterExportChanged,
    required this.onAutoTransferToPhoneChanged,
    required this.onExport,
    required this.onPreview,
    required this.onReset,
    required this.statusMessage,
  });

  final bool isExporting;
  final bool isPreviewing;
  final bool printAfterExport;
  final bool autoTransferToPhone;
  final ValueChanged<bool> onPrintAfterExportChanged;
  final ValueChanged<bool> onAutoTransferToPhoneChanged;
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
            const Spacer(),
            Tooltip(
              message: 'Sau khi export, mở hộp thoại in Windows (spooler → driver máy in)',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('In sau export'),
                  const SizedBox(width: 4),
                  Switch(
                    value: printAfterExport,
                    onChanged: isExporting || isPreviewing ? null : onPrintAfterExportChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: 'Tự thử gửi ảnh sang Android qua cáp USB (MTP/File Transfer).',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gửi sang điện thoại'),
                  const SizedBox(width: 4),
                  Switch(
                    value: autoTransferToPhone,
                    onChanged: isExporting || isPreviewing ? null : onAutoTransferToPhoneChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            statusMessage!,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
