import 'dart:io';

import 'package:path/path.dart' as p;

class AppPaths {
  AppPaths({required this.rootDirectory}) : rootDirectory = _normalize(rootDirectory);

  final String rootDirectory;

  String get inboxDirectory => p.join(rootDirectory, 'inbox');
  String get exportsDirectory => p.join(rootDirectory, 'exports');
  String get templatesDirectory => p.join(rootDirectory, 'templates');

  static AppPaths defaultWindows() {
    final userProfile = Platform.environment['USERPROFILE'];
    final fallbackBase = userProfile != null && userProfile.isNotEmpty
        ? p.join(userProfile, 'PhotoStudio')
        : p.join(Directory.current.path, 'PhotoStudio');
    return AppPaths(rootDirectory: fallbackBase);
  }

  static String _normalize(String input) {
    final normalized = p.normalize(input.trim());
    if (normalized.contains('..')) {
      throw ArgumentError('Root directory must not contain parent traversal segments.');
    }
    return normalized;
  }
}
