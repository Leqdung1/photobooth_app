import 'dart:io';

import 'package:path/path.dart' as p;

class AppPaths {
  AppPaths({
    required String rootDirectory,
    String? inboxDirectory,
  })  : rootDirectory = _normalize(rootDirectory),
        inboxDirectory = inboxDirectory != null
            ? _normalize(inboxDirectory)
            : p.join(_normalize(rootDirectory), 'inbox');

  final String rootDirectory;
  final String inboxDirectory;

  String get exportsDirectory => p.join(rootDirectory, 'exports');
  String get templatesDirectory => p.join(rootDirectory, 'templates');

  static AppPaths defaultWindows({String? inboxDirectory}) {
    final userProfile = Platform.environment['USERPROFILE'];
    final fallbackBase = userProfile != null && userProfile.isNotEmpty
        ? p.join(userProfile, 'PhotoStudio')
        : p.join(Directory.current.path, 'PhotoStudio');
    return AppPaths(rootDirectory: fallbackBase, inboxDirectory: inboxDirectory);
  }

  static String _normalize(String input) {
    final normalized = p.normalize(input.trim());
    if (normalized.contains('..')) {
      throw ArgumentError('Root directory must not contain parent traversal segments.');
    }
    return normalized;
  }
}
