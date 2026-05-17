import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/photo_asset.dart';

class FolderWatchService {
  FolderWatchService();

  static const _supportedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  final Set<String> _seenPaths = <String>{};

  void resetSeen() {
    _seenPaths.clear();
  }

  Stream<PhotoAsset> watch(String folderPath) async* {
    final directory = Directory(folderPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    await for (final event in directory.watch(events: FileSystemEvent.create | FileSystemEvent.modify)) {
      if (event is! FileSystemCreateEvent && event is! FileSystemModifyEvent) {
        continue;
      }
      final asset = await _tryBuildAsset(event.path);
      if (asset != null) {
        yield asset;
      }
    }
  }

  Future<PhotoAsset?> _tryBuildAsset(String rawPath) async {
    final extension = p.extension(rawPath).toLowerCase();
    if (!_supportedExtensions.contains(extension)) {
      return null;
    }

    final normalized = p.normalize(rawPath);
    if (_seenPaths.contains(normalized)) {
      return null;
    }

    File file = File(normalized);
    const retryLimit = 8;
    for (var attempt = 0; attempt < retryLimit; attempt++) {
      try {
        final length = await file.length();
        if (length > 0) {
          final stat = await file.stat();
          _seenPaths.add(normalized);
          return PhotoAsset(
            id: normalized,
            path: normalized,
            createdAt: stat.modified,
          );
        }
      } catch (_) {
        // Retry while file is being copied.
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    return null;
  }
}
