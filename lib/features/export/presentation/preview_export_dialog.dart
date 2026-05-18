import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Dialog UI for: preview image (left) + export settings (right) + Start Now.
///
/// - The preview is built immediately when dialog opens.
/// - Start Now triggers export only.
class PreviewExportDialog extends StatefulWidget {
  const PreviewExportDialog({
    super.key,
    required this.buildPreview,
    required this.onStartExport,
    required this.initialPrintAfterExport,
    required this.initialSendToMobile,
  });

  final Future<Uint8List?> Function() buildPreview;
  final Future<void> Function(
      {required bool printAfterExport,
      required bool sendToMobile}) onStartExport;
  final bool initialPrintAfterExport;
  final bool initialSendToMobile;

  @override
  State<PreviewExportDialog> createState() => _PreviewExportDialogState();
}

class _PreviewExportDialogState extends State<PreviewExportDialog> {
  late bool _printAfterExport = widget.initialPrintAfterExport;
  late bool _sendToMobile = widget.initialSendToMobile;

  Uint8List? _previewBytes;
  String? _previewError;
  bool _loadingPreview = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _loadingPreview = true;
      _previewError = null;
    });

    try {
      final bytes = await widget.buildPreview();
      if (!mounted) return;
      setState(() {
        _previewBytes = bytes;
        _loadingPreview = false;
        _previewError = bytes == null ? 'Preview failed.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _previewBytes = null;
        _loadingPreview = false;
        _previewError = e.toString();
      });
    }
  }

  Future<void> _handleStartNow() async {
    if (_exporting) return;
    setState(() {
      _exporting = true;
    });
    try {
      await widget.onStartExport(
        printAfterExport: _printAfterExport,
        sendToMobile: _sendToMobile,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (!mounted) return;
      setState(() {
        _exporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: const Color(0xFF1A2747),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.88,
          maxHeight: size.height * 0.86,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Preview & Export',
                      style: TextStyle(
                          color: Color(0xFFE6EEFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: _exporting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close, color: Color(0xFFBFD2FF)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2A3A62)),
            Expanded(
              child: Row(
                children: [
                  // Left: preview image
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1D3D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A3A62)),
                        ),
                        child: Center(
                          child: _loadingPreview
                              ? const CircularProgressIndicator()
                              : (_previewBytes == null)
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.broken_image_outlined,
                                            color: Color(0xFFB8C7EA)),
                                        const SizedBox(height: 8),
                                        Text(
                                          _previewError ??
                                              'Preview unavailable',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Color(0xFFB8C7EA)),
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: _loadPreview,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    )
                                  : InteractiveViewer(
                                      minScale: 0.6,
                                      maxScale: 3.5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Center(
                                          child: Image.memory(_previewBytes!,
                                              fit: BoxFit.contain),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ),
                  // Right: settings
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'EXPORT SETTINGS',
                            style: TextStyle(
                              color: Color(0xFF90A6D8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingToggle(
                            icon: Icons.print_outlined,
                            label: 'Print after export',
                            value: _printAfterExport,
                            onChanged: _exporting
                                ? null
                                : (v) {
                                    setState(() => _printAfterExport = v);
                                  },
                          ),
                          const SizedBox(height: 10),
                          _SettingToggle(
                            icon: Icons.phone_android_outlined,
                            label: 'Send to Mobile',
                            value: _sendToMobile,
                            onChanged: _exporting
                                ? null
                                : (v) {
                                    setState(() => _sendToMobile = v);
                                  },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1D3D),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFF2A3A62)),
                            ),
                            child: const Text(
                              'Your collage will be exported in high-quality PNG format for optimal printing results.',
                              style: TextStyle(
                                  color: Color(0xFFB8C7EA),
                                  fontSize: 12,
                                  height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2A3A62)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: (_exporting || _loadingPreview)
                          ? null
                          : _handleStartNow,
                      icon: _exporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.rocket_launch_outlined, size: 18),
                      label: Text(_exporting ? 'Processing...' : 'Start Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF233158),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3A62)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFBFD2FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: Color(0xFFE6EEFF), fontWeight: FontWeight.w600),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
