import 'dart:async';

import 'package:flutter/material.dart';

import 'core/config/app_paths.dart';
import 'core/config/startup_validator.dart';
import 'features/composer/application/composer_controller.dart';
import 'features/composer/presentation/composer_grid.dart';
import 'features/composer/presentation/preview_panel.dart';
import 'features/export/application/export_service.dart';
import 'features/export/domain/export_request.dart';
import 'features/export/presentation/export_actions.dart';
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
  final _paths = AppPaths.defaultWindows();
  final _startupValidator = const StartupValidator();
  final _watchService = FolderWatchService();
  final _thumbnailService = const ThumbnailService();
  final _composerController = ComposerController();
  final _exportService = ExportService();

  final List<PhotoAsset> _assets = <PhotoAsset>[];
  StreamSubscription<PhotoAsset>? _watchSubscription;

  String? _selectedAssetId;
  int _selectedSlot = 1;
  String? _statusMessage;
  bool _initializing = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final validation = await _startupValidator.ensureFolders(_paths);
    _statusMessage = validation.messages.join('\n');

    if (validation.success) {
      _watchSubscription = _watchService.watch(_paths.inboxDirectory).listen((asset) async {
        final thumb = await _thumbnailService.generate(asset.path);
        final enriched = asset.copyWith(thumbnailPath: thumb);
        if (!mounted) return;

        setState(() {
          final exists = _assets.any((item) => item.id == enriched.id);
          if (!exists) {
            _assets.add(enriched);
            _assets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }
        });
      });
    }

    if (!mounted) return;
    setState(() {
      _initializing = false;
    });
  }

  @override
  void dispose() {
    _watchSubscription?.cancel();
    _composerController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Export is running...';
    });

    final request = ExportRequest(
      slotPaths: _composerController.slots.map((slot) => slot.assetPath).toList(growable: false),
      exportsDirectory: _paths.exportsDirectory,
    );
    final result = await _exportService.export(request);

    if (!mounted) return;
    setState(() {
      _isExporting = false;
      _statusMessage = result.success ? 'Exported: ${result.filePath}' : (result.error ?? 'Export failed');
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

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Booth MVP')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 320,
              child: GalleryPanel(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Target slot:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _selectedSlot,
                        items: const [1, 2, 3, 4]
                            .map((slot) => DropdownMenuItem<int>(value: slot, child: Text('Slot $slot')))
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedSlot = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 360,
                    child: AnimatedBuilder(
                      animation: _composerController,
                      builder: (_, __) => ComposerGrid(
                        slots: _composerController.slots,
                        selectedSlot: _selectedSlot,
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
                  AnimatedBuilder(
                    animation: _composerController,
                    builder: (_, __) => PreviewPanel(slots: _composerController.slots),
                  ),
                  const SizedBox(height: 12),
                  ExportActions(
                    isExporting: _isExporting,
                    onExport: _handleExport,
                    onReset: () {
                      _composerController.resetAll();
                      setState(() {
                        _statusMessage = 'Slots reset.';
                      });
                    },
                    statusMessage: _statusMessage,
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
