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

  @override
  Widget build(BuildContext context) {
    final busy = isExporting || isPreviewing;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : onExport,
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(isExporting ? 'Exporting...' : 'Export ảnh'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(isPreviewing ? 'Đang tạo...' : 'Preview'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset slot'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 6,
              children: [
                Tooltip(
                  message: 'Sau khi export, mở hộp thoại in Windows (spooler → driver máy in)',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('In sau export'),
                      Switch(
                        value: printAfterExport,
                        onChanged: busy ? null : onPrintAfterExportChanged,
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Tự thử gửi ảnh sang Android qua cáp USB (MTP/File Transfer).',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Gửi điện thoại'),
                      Switch(
                        value: autoTransferToPhone,
                        onChanged: busy ? null : onAutoTransferToPhoneChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
