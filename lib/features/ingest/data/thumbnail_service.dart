import 'dart:io';

class ThumbnailService {
  const ThumbnailService();

  Future<String?> generate(String sourcePath) async {
    final file = File(sourcePath);
    if (await file.exists()) {
      return sourcePath;
    }
    return null;
  }
}
