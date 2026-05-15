import 'dart:io';

import 'app_paths.dart';

class StartupValidationResult {
  const StartupValidationResult({required this.success, required this.messages});

  final bool success;
  final List<String> messages;
}

class StartupValidator {
  const StartupValidator();

  Future<StartupValidationResult> ensureFolders(AppPaths paths) async {
    final messages = <String>[];

    final folders = <String, bool>{
      paths.inboxDirectory: _isUnderRoot(paths.inboxDirectory, paths.rootDirectory),
      paths.exportsDirectory: true,
      paths.templatesDirectory: true,
    };

    for (final entry in folders.entries) {
      final folder = entry.key;
      final createIfMissing = entry.value;
      final directory = Directory(folder);
      try {
        if (!await directory.exists()) {
          if (!createIfMissing) {
            messages.add('Inbox folder not found: $folder');
            continue;
          }
          await directory.create(recursive: true);
          messages.add('Created $folder');
        }
      } on FileSystemException catch (error) {
        messages.add('Failed to prepare $folder: ${error.message}');
      }
    }

    final hasError = messages.any((message) => message.startsWith('Failed'));
    if (!hasError && messages.isEmpty) {
      messages.add('Environment folders are ready.');
    }

    return StartupValidationResult(success: !hasError, messages: messages);
  }

  bool _isUnderRoot(String folder, String root) {
    final normalizedFolder = folder.replaceAll('/', '\\').toLowerCase();
    final normalizedRoot = root.replaceAll('/', '\\').toLowerCase();
    return normalizedFolder.startsWith('$normalizedRoot\\');
  }
}
