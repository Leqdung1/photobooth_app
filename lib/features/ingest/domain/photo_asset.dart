class PhotoAsset {
  const PhotoAsset({
    required this.id,
    required this.path,
    required this.createdAt,
    this.thumbnailPath,
  });

  final String id;
  final String path;
  final DateTime createdAt;
  final String? thumbnailPath;

  PhotoAsset copyWith({String? thumbnailPath}) {
    return PhotoAsset(
      id: id,
      path: path,
      createdAt: createdAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
