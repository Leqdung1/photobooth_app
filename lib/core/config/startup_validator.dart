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

    for (final folder in [paths.inboxDirectory, paths.exportsDirectory, paths.templatesDirectory]) {
      final directory = Directory(folder);
      try {
        if (!await directory.exists()) {
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
}
