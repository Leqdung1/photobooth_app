import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppSettings {
  const AppSettings({this.inboxDirectory});

  final String? inboxDirectory;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'inboxDirectory': inboxDirectory,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final value = json['inboxDirectory']?.toString();
    return AppSettings(inboxDirectory: value == null || value.trim().isEmpty ? null : value);
  }
}

class AppSettingsRepository {
  const AppSettingsRepository();

  Future<AppSettings> load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) return const AppSettings();
      final text = await file.readAsString();
      if (text.trim().isEmpty) return const AppSettings();
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        return AppSettings.fromJson(decoded);
      }
      if (decoded is Map) {
        return AppSettings.fromJson(decoded.map((k, v) => MapEntry(k.toString(), v)));
      }
      return const AppSettings();
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    final file = await _settingsFile();
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(jsonEncode(settings.toJson()), flush: true);
  }

  Future<File> _settingsFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'photo_booth_settings.json'));
  }
}

