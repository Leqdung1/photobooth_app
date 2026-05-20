import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'core/config/app_paths.dart';
import 'core/config/app_settings_repository.dart';
import 'core/config/startup_validator.dart';
import 'features/composer/application/composer_controller.dart';
import 'features/composer/domain/frame_template.dart';
import 'features/composer/presentation/composer_grid.dart';
import 'features/composer/presentation/preview_panel.dart';
import 'features/export/application/export_service.dart';
import 'features/export/application/phone_transfer_service.dart';
import 'features/export/application/windows_android_transfer_service.dart';
import 'features/export/application/windows_print_service.dart';
import 'features/export/domain/export_request.dart';
import 'features/export/domain/phone_transfer_request.dart';
import 'features/export/presentation/export_preview_dialog.dart';
import 'features/export/presentation/preview_export_dialog.dart';
import 'features/ingest/data/folder_watch_service.dart';
import 'features/ingest/data/thumbnail_service.dart';
import 'features/ingest/domain/photo_asset.dart';
import 'features/ingest/presentation/gallery_panel.dart';

void main() {
  runApp(const PhotoBoothApp());
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Booth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF3F5FA),
      ),
      home: const PhotoBoothHomePage(),
    );
  }
}

class PhotoBoothHomePage extends StatefulWidget {
  const PhotoBoothHomePage({super.key});

  @override
  State<PhotoBoothHomePage> createState() => _PhotoBoothHomePageState();
}

class _PhotoBoothHomePageState extends State<PhotoBoothHomePage> {
  late AppPaths _paths;
  final _settingsRepository = const AppSettingsRepository();
  final _startupValidator = const StartupValidator();
  FolderWatchService _watchService = FolderWatchService();
  final _thumbnailService = const ThumbnailService();
  final _composerController = ComposerController();
  final _exportService = ExportService();
  final PhoneTransferService _phoneTransferService = const WindowsAndroidTransferService();
  final _printService = const WindowsPrintService();

  List<PhotoAsset> _assets = <PhotoAsset>[];
  StreamSubscription<PhotoAsset>? _watchSubscription;
  int _folderRequestId = 0;

  String? _selectedAssetId;
  int _selectedSlot = 1;
  FrameTemplate _selectedTemplate = FrameTemplate.oneByTwo;
  String? _statusMessage;
  bool _initializing = true;
  bool _isExporting = false;
  bool _isPreviewing = false;
  bool _printAfterExport = true;
  bool _autoTransferToPhone = true;

  static const _bgColor = Color(0xFF0B1633);
  static const _panelColor = Color(0xFF172344);
  static const _panelBorder = Color(0xFF2A3A62);
  static const _panelInner = Color(0xFF0F1D3D);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final settings = await _settingsRepository.load();
    final initialInbox = settings.inboxDirectory ?? AppPaths.defaultInboxDirectoryWindows();
    _paths = AppPaths.defaultWindows(inboxDirectory: initialInbox);

    await _restartWatch();

    if (!mounted) return;
    setState(() {
      _initializing = false;
    });
  }

  Future<void> _restartWatch() async {
    final requestId = ++_folderRequestId;

    final previousSubscription = _watchSubscription;
    _watchSubscription = null;
    if (previousSubscription != null) {
      unawaited(
        previousSubscription
            .cancel()
            .timeout(const Duration(seconds: 1), onTimeout: () {}),
      );
    }
    _watchService = FolderWatchService();
    _watchService.resetSeen();

    if (mounted) {
      setState(() {
        _assets = <PhotoAsset>[];
      });
    } else {
      _assets = <PhotoAsset>[];
    }

    final inboxDir = _paths.inboxDirectory;

    // Immediately reflect the folder switch in UI and clear the list.
    if (mounted) {
      setState(() {
        _statusMessage = null;
        _assets = <PhotoAsset>[];
      });
    } else {
      _assets = <PhotoAsset>[];
    }

    final validation = await _startupValidator.ensureFolders(_paths);
    if (requestId != _folderRequestId) return;

    if (mounted) {
      setState(() {
        _statusMessage = null;
      });
    } else {
      _statusMessage = null;
    }

    if (validation.success) {
      final loadedCount = await _loadExistingAssetsFromInbox(requestId: requestId);
      if (requestId != _folderRequestId) return;

      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }

      _watchSubscription = _watchService.watch(inboxDir).listen(
        (asset) async {
          if (requestId != _folderRequestId) return;

          final thumb = await _thumbnailService.generate(asset.path);
          if (requestId != _folderRequestId) return;

          final enriched = asset.copyWith(thumbnailPath: thumb);
          if (!mounted) return;

          setState(() {
            final exists = _assets.any((item) => item.id == enriched.id);
            if (!exists) {
              _assets = <PhotoAsset>[..._assets, enriched]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }
          });
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _statusMessage = 'Lang nghe thu muc that bai ($inboxDir): $error';
          });
        },
      );
    }
  }

  Future<int> _loadExistingAssetsFromInbox({required int requestId}) async {
    // Snapshot the target directory at call time to guard against races
    // when the user switches folders quickly.
    final targetDir = _paths.inboxDirectory;
    final directory = Directory(targetDir);
    if (!await directory.exists()) return 0;

    final loaded = <PhotoAsset>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final lower = entity.path.toLowerCase();
      if (!(lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp'))) {
        continue;
      }

      try {
        final stat = await entity.stat();
        if (stat.size <= 0) continue;
        loaded.add(
          PhotoAsset(
            id: entity.path,
            path: entity.path,
            createdAt: stat.modified,
            thumbnailPath: null,
          ),
        );
      } catch (_) {
        // Skip broken file
      }
    }

    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // If the user switched folders again while we were scanning, discard results.
    if (!mounted ||
        _paths.inboxDirectory != targetDir ||
        requestId != _folderRequestId) {
      return loaded.length;
    }

    setState(() {
      _assets = List<PhotoAsset>.from(loaded);
      _selectedAssetId = null;
    });

    // Generate thumbnails in the background so the gallery updates immediately
    // without requiring an app reload.
    unawaited(_generateThumbnailsForAssets(loaded, requestId: requestId));
    return loaded.length;
  }

  Future<void> _generateThumbnailsForAssets(List<PhotoAsset> assets, {required int requestId}) async {
    for (final asset in assets) {
      if (requestId != _folderRequestId) return;

      try {
        final thumb = await _thumbnailService.generate(asset.path);
        if (requestId != _folderRequestId) return;

        if (!mounted) return;
        setState(() {
          final index = _assets.indexWhere((item) => item.id == asset.id);
          if (index >= 0) {
            final updated = List<PhotoAsset>.from(_assets);
            updated[index] = updated[index].copyWith(thumbnailPath: thumb);
            _assets = updated;
          }
        });
      } catch (_) {
        // Ignore thumbnail errors; original image path is still usable.
      }
    }
  }

  Future<void> _pickInboxFolder() async {
    setState(() {
      _statusMessage = null;
    });

    try {
      final selected = await getDirectoryPath(
        initialDirectory: Directory(_paths.inboxDirectory).existsSync() ? _paths.inboxDirectory : null,
        confirmButtonText: 'Chọn thư mục này',
      );
      if (selected == null || selected.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          _statusMessage = null;
        });
        return;
      }

      final next = AppPaths.defaultWindows(inboxDirectory: selected);
      if (!mounted) return;
      setState(() {
        _paths = next;
        _statusMessage = null;
      });

      await _settingsRepository.save(AppSettings(inboxDirectory: selected));
      await _restartWatch();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Không thể chọn thư mục: $error';
      });
    }
  }

  @override
  void dispose() {
    _watchSubscription?.cancel();
    _composerController.dispose();
    super.dispose();
  }

  ExportRequest _buildExportRequest() {
    return ExportRequest(
      slots: _composerController.slots
          .map(
            (slot) => ExportSlot(
              assetPath: slot.assetPath,
              scale: slot.scale,
              offsetX: slot.offsetX,
              offsetY: slot.offsetY,
            ),
          )
          .toList(growable: false),
      exportsDirectory: _paths.exportsDirectory,
      rows: _selectedTemplate.rows,
      columns: _selectedTemplate.columns,
      template: _selectedTemplate,
    );
  }

  Future<void> _handlePreview() async {
    setState(() {
      _isPreviewing = true;
      _statusMessage = 'Đang tạo preview...';
    });

    final result = await _exportService.buildPreview(_buildExportRequest());

    if (!mounted) return;
    setState(() {
      _isPreviewing = false;
      _statusMessage = result.success ? null : result.error;
    });

    if (!result.success || result.imageBytes == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) => ExportPreviewDialog(imageBytes: result.imageBytes!),
    );
  }

  Future<Uint8List?> _buildPreviewBytes() async {
    final result = await _exportService.buildPreview(_buildExportRequest());
    if (!result.success) {
      return null;
    }
    return result.imageBytes;
  }

  Future<void> _handleExportWithSettings({required bool printAfterExport, required bool sendToMobile}) async {
    setState(() {
      _isExporting = true;
    });

    final result = await _exportService.export(_buildExportRequest());
    if (!mounted) return;

    var ok = result.success;
    var message = ok ? 'Export successful' : (result.error ?? 'Export failed');

    if (ok && result.filePath != null && sendToMobile) {
      final transferResult = await _phoneTransferService.transfer(
        PhoneTransferRequest(sourceFilePath: result.filePath!),
      );
      message = '$message\nMobile: ${transferResult.message}';
      if (!transferResult.isSuccess) {
        ok = false;
      }
    }

    if (ok && result.filePath != null && printAfterExport) {
      try {
        await _printService.printImageFile(result.filePath!);
      } catch (error) {
        message = '$message\nPrint failed: $error';
        ok = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _isExporting = false;
    });

    _showBottomRightToast(context, title: ok ? 'Export Successful!' : 'Export Failed', message: message, ok: ok);
  }

  void _showBottomRightToast(
    BuildContext context, {
    required String title,
    required String message,
    required bool ok,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          right: 20,
          bottom: 20,
          child: _ToastCard(title: title, message: message, ok: ok),
        );
      },
    );

    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 4)).then((_) {
      entry.remove();
    });
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Export is running...';
    });

    final result = await _exportService.export(_buildExportRequest());

    if (!mounted) return;
    var message = result.success ? 'Exported: ${result.filePath}' : (result.error ?? 'Export failed');

    if (result.success && result.filePath != null && _autoTransferToPhone) {
      final transferResult = await _phoneTransferService.transfer(
        PhoneTransferRequest(sourceFilePath: result.filePath!),
      );
      message = '$message\nUSB transfer: ${transferResult.message}';
    }

    if (result.success && result.filePath != null && _printAfterExport) {
      try {
        await _printService.printImageFile(result.filePath!);
      } catch (error, stackTrace) {
        assert(() {
          debugPrint('Print failed: $error\n$stackTrace');
          return true;
        }());
        message = '$message\n(Lỗi in: $error)';
      }
    }

    if (!mounted) return;
    setState(() {
      _isExporting = false;
      _statusMessage = message;
    });
  }

  void _assignSelectedAssetToSlot() {
    final matches = _assets.where((asset) => asset.id == _selectedAssetId);
    final selected = matches.isEmpty ? null : matches.first;
    if (selected == null) return;
    _composerController.assign(slotIndex: _selectedSlot, assetPath: selected.path);
    setState(() {});
  }

  void _handleResetSlots() {
    _composerController.resetAll();
    setState(() {});
  }

  void _onPrintAfterExportChanged(bool value) {
    setState(() {
      _printAfterExport = value;
    });
  }

  void _onAutoTransferToPhoneChanged(bool value) {
    setState(() {
      _autoTransferToPhone = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final composerWidgets = <Widget>[
      Card(
        margin: EdgeInsets.zero,
        color: _panelColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _panelBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: SizedBox(
                height: 660,
                child: AnimatedBuilder(
                  animation: _composerController,
                  builder: (_, __) {
                    return ComposerGrid(
                      slots: _composerController.slots,
                      selectedSlot: _selectedSlot,
                      template: _selectedTemplate,
                      columns: _selectedTemplate.columns,
                      aspectRatio: _selectedTemplate.previewAspectRatio,
                      onSlotSelected: (slot) {
                        setState(() {
                          _selectedSlot = slot;
                        });
                      },
                      onTransformChanged: ({required slotIndex, required scale, required offsetX, required offsetY}) {
                        _composerController.updateTransform(
                          slotIndex: slotIndex,
                          scale: scale,
                          offsetX: offsetX,
                          offsetY: offsetY,
                        );
                      },
                      onClearSlot: (slot) {
                        _composerController.clearSlot(slot);
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _panelColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _panelBorder),
              ),
              child: Row(
                children: [
                  const Text('Inbox', style: TextStyle(color: Color(0xFFE6EEFF), fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  const Text('/', style: TextStyle(color: Color(0xFF7D92C5))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paths.inboxDirectory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFB8C7EA)),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickInboxFolder,
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFBFD2FF)),
                    child: const Text('Change Folder', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 290,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _panelColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _panelBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                            child: Text(
                              'Library',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: GalleryPanel(
                                key: ValueKey(_paths.inboxDirectory),
                                assets: _assets,
                                selectedAssetId: _selectedAssetId,
                                onAssetSelected: (asset) {
                                  setState(() {
                                    _selectedAssetId = asset.id;
                                  });
                                  _assignSelectedAssetToSlot();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _panelInner,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _panelBorder),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 84),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: composerWidgets,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 18,
                            child: Center(
                              child: SizedBox(
                                width: 220,
                                height: 44,
                                child: FilledButton.icon(
                                  onPressed: (_isExporting || _isPreviewing)
                                      ? null
                                      : () async {
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (context) => PreviewExportDialog(
                                              buildPreview: _buildPreviewBytes,
                                              onStartExport: ({required printAfterExport, required sendToMobile}) async {
                                                await _handleExportWithSettings(
                                                  printAfterExport: printAfterExport,
                                                  sendToMobile: sendToMobile,
                                                );
                                              },
                                              initialPrintAfterExport: _printAfterExport,
                                              initialSendToMobile: _autoTransferToPhone,
                                            ),
                                          );
                                        },
                                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                                  label: const Text('Preview & Export'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 260,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _panelColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _panelBorder),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Templates',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'BASIC LAYOUTS',
                            style: TextStyle(
                              color: Color(0xFF90A6D8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 260),
                                child: GridView.builder(
                                  itemCount: FrameTemplate.presets.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemBuilder: (context, index) {
                                    final template = FrameTemplate.presets[index];
                                    final isSelected = _selectedTemplate.id == template.id;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        _composerController.setTemplate(template);
                                        setState(() {
                                          _selectedTemplate = template;
                                          _selectedSlot = 1;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF263A6F) : const Color(0xFF223059),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                isSelected ? const Color(0xFF93B2FF) : const Color(0xFF324879),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(child: _TemplateMiniPreview(template: template)),
                                            const SizedBox(height: 6),
                                            Text(
                                              template.label,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFFD5E3FF),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Status banner intentionally hidden in the new UI.
        ],
      ),
    );
  }
}

class _TemplateMiniPreview extends StatelessWidget {
  const _TemplateMiniPreview({required this.template});

  final FrameTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101C38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334B7D)),
      ),
      padding: const EdgeInsets.all(5),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: template.slotCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: template.columns,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A284A),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFF415C95)),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({required this.title, required this.message, required this.ok});

  final String title;
  final String message;
  final bool ok;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1F2F55),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.ok ? const Color(0xFF3D9A68) : const Color(0xFFB04040)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.ok ? Icons.check_circle_outline : Icons.error_outline,
                  color: widget.ok ? const Color(0xFF5CC891) : const Color(0xFFE07070),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.ok ? const Color(0xFF5CC891) : const Color(0xFFE07070),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: const TextStyle(color: Color(0xFFB8C7EA), fontSize: 12, height: 1.3),
                      ),
                    ],
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
