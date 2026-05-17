import 'dart:async';
import 'dart:io';

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
import 'features/export/presentation/export_actions.dart';
import 'features/export/presentation/export_preview_dialog.dart';
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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
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
        _statusMessage = 'Dang ap dung thu muc moi: $inboxDir';
        _assets = <PhotoAsset>[];
      });
    } else {
      _assets = <PhotoAsset>[];
    }

    final validation = await _startupValidator.ensureFolders(_paths);
    if (requestId != _folderRequestId) return;

    if (mounted) {
      setState(() {
        _statusMessage = validation.messages.join('\n');
      });
    } else {
      _statusMessage = validation.messages.join('\n');
    }

    if (validation.success) {
      final loadedCount = await _loadExistingAssetsFromInbox(requestId: requestId);
      if (requestId != _folderRequestId) return;

      if (mounted) {
        setState(() {
          _statusMessage = 'Da doi thu muc: $inboxDir (tai $loadedCount anh).';
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
      _statusMessage = 'Đang chọn thư mục ảnh nhận...';
    });

    try {
      final selected = await getDirectoryPath(
        initialDirectory: Directory(_paths.inboxDirectory).existsSync() ? _paths.inboxDirectory : null,
        confirmButtonText: 'Chọn thư mục này',
      );
      if (selected == null || selected.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Đã hủy chọn thư mục.';
        });
        return;
      }

      final next = AppPaths.defaultWindows(inboxDirectory: selected);
      if (!mounted) return;
      setState(() {
        _paths = next;
        _statusMessage = 'Đang áp dụng thư mục mới: ${_paths.inboxDirectory}';
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
      slotPaths: _composerController.slots.map((slot) => slot.assetPath).toList(growable: false),
      exportsDirectory: _paths.exportsDirectory,
      rows: _selectedTemplate.rows,
      columns: _selectedTemplate.columns,
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

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final panelHeight = MediaQuery.sizeOf(context).height - kToolbarHeight - 24 - 56;

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Booth MVP')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.folder, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thư mục nhận ảnh: ${_paths.inboxDirectory}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _pickInboxFolder,
                    icon: const Icon(Icons.sync_alt, size: 16),
                    label: const Text('Đổi thư mục'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    height: panelHeight,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: panelHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Frame:'),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedTemplate.id,
                                items: FrameTemplate.presets
                                    .map(
                                      (template) => DropdownMenuItem<String>(
                                        value: template.id,
                                        child: Text(template.label),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (value) {
                                  if (value == null) return;
                                  final template = FrameTemplate.presets.firstWhere((item) => item.id == value);
                                  _composerController.setTemplate(template);
                                  setState(() {
                                    _selectedTemplate = template;
                                    _selectedSlot = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 420,
                                    child: AnimatedBuilder(
                                      animation: _composerController,
                                      builder: (_, __) => ComposerGrid(
                                        slots: _composerController.slots,
                                        selectedSlot: _selectedSlot,
                                        columns: _selectedTemplate.columns,
                                        onSlotSelected: (slot) {
                                          setState(() {
                                            _selectedSlot = slot;
                                          });
                                        },
                                        onClearSlot: (slot) {
                                          _composerController.clearSlot(slot);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 280,
                                    child: AnimatedBuilder(
                                      animation: _composerController,
                                      builder: (_, __) => PreviewPanel(
                                        slots: _composerController.slots,
                                        columns: _selectedTemplate.columns,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ExportActions(
                                    isExporting: _isExporting,
                                    isPreviewing: _isPreviewing,
                                    printAfterExport: _printAfterExport,
                                    autoTransferToPhone: _autoTransferToPhone,
                                    onPrintAfterExportChanged: (value) {
                                      setState(() {
                                        _printAfterExport = value;
                                      });
                                    },
                                    onAutoTransferToPhoneChanged: (value) {
                                      setState(() {
                                        _autoTransferToPhone = value;
                                      });
                                    },
                                    onExport: _handleExport,
                                    onPreview: _handlePreview,
                                    onReset: () {
                                      _composerController.resetAll();
                                      setState(() {});
                                    },
                                  ),
                                ],
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
        ],
      ),
    );
  }
}
