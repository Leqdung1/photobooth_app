import 'dart:io';

import 'package:path/path.dart' as p;

class AppPaths {
  AppPaths({
    required String rootDirectory,
    String? inboxDirectory,
    String? exportsDirectory,
    this.exportsUseOneDriveSync = false,
  })  : rootDirectory = _normalize(rootDirectory),
        inboxDirectory = inboxDirectory != null
            ? _normalize(inboxDirectory)
            : p.join(_normalize(rootDirectory), 'inbox'),
        exportsDirectory = exportsDirectory != null
            ? _normalize(exportsDirectory)
            : p.join(_normalize(rootDirectory), 'exports');

  final String rootDirectory;
  final String inboxDirectory;

  /// Final frame (PNG) is written here — prefer OneDrive so the same folder syncs to the phone app.
  final String exportsDirectory;

  /// When true, [exportsDirectory] is under OneDrive (`PhotoBoothSync`).
  final bool exportsUseOneDriveSync;

  String get templatesDirectory => p.join(rootDirectory, 'templates');

  /// Short hint for UI about how files reach the phone.
  String get phoneSyncHint {
    if (exportsUseOneDriveSync) {
      return 'Export PNG → OneDrive/PhotoBoothSync. Có thể bật thêm USB transfer (Android/MTP) ngay sau export.';
    }
    return 'Export PNG → $exportsDirectory — có thể bật USB transfer (Android/MTP) hoặc cài OneDrive để đồng bộ tự động.';
  }

  static AppPaths defaultWindows({String? inboxDirectory}) {
    final userProfile = Platform.environment['USERPROFILE'];
    final fallbackBase = userProfile != null && userProfile.isNotEmpty
        ? p.join(userProfile, 'PhotoStudio')
        : p.join(Directory.current.path, 'PhotoStudio');

    final resolved = _defaultExportsDirectory(fallbackBase);
    return AppPaths(
      rootDirectory: fallbackBase,
      inboxDirectory: inboxDirectory,
      exportsDirectory: resolved.path,
      exportsUseOneDriveSync: resolved.usesOneDrive,
    );
  }

  static String defaultInboxDirectoryWindows() {
    final oneDrive = Platform.environment['OneDrive'] ?? Platform.environment['OneDriveCommercial'];
    if (oneDrive != null && oneDrive.trim().isNotEmpty) {
      final oneDrivePictures = p.normalize(p.join(oneDrive.trim(), 'Pictures'));
      if (Directory(oneDrivePictures).existsSync()) {
        return oneDrivePictures;
      }
    }

    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null && userProfile.trim().isNotEmpty) {
      final pictures = p.normalize(p.join(userProfile.trim(), 'Pictures'));
      if (Directory(pictures).existsSync()) {
        return pictures;
      }
      return pictures;
    }

    return p.normalize(p.join(Directory.current.path, 'inbox'));
  }

  /// OneDrive `PhotoBoothSync` when available; otherwise `[root]/exports` under PhotoStudio.
  static ({String path, bool usesOneDrive}) _defaultExportsDirectory(String photoStudioRoot) {
    final oneDrive = Platform.environment['OneDrive'] ?? Platform.environment['OneDriveCommercial'];
    if (oneDrive != null && oneDrive.trim().isNotEmpty) {
      final root = p.normalize(oneDrive.trim());
      if (Directory(root).existsSync()) {
        return (path: p.join(root, 'PhotoBoothSync'), usesOneDrive: true);
      }
    }
    return (path: p.join(photoStudioRoot, 'exports'), usesOneDrive: false);
  }

  static String _normalize(String input) {
    final normalized = p.normalize(input.trim());
    if (normalized.contains('..')) {
      throw ArgumentError('Root directory must not contain parent traversal segments.');
    }
    return normalized;
  }
}
