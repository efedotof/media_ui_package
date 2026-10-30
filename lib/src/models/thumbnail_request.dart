class ThumbnailRequest {
  final String mediaId;
  final String mediaType;
  final int width;
  final int height;

  const ThumbnailRequest({
    required this.mediaId,
    required this.mediaType,
    this.width = 200,
    this.height = 200,
  });

  String get cacheKey => '$mediaId:${mediaType.toLowerCase()}:${width}x$height';

  bool get isValid =>
      mediaId.isNotEmpty &&
      (mediaType == 'image' || mediaType == 'video') &&
      width > 0 &&
      height > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThumbnailRequest &&
          other.mediaId == mediaId &&
          other.mediaType == mediaType &&
          other.width == width &&
          other.height == height;

  @override
  int get hashCode => cacheKey.hashCode;

  @override
  String toString() => 'ThumbnailRequest($cacheKey)';
}
