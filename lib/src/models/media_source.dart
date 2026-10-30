enum MediaSource {
  device,

  downloads,

  documents,

  picked,

  dropped,

  unknown;

  String get value => name;

  static MediaSource fromString(String? value) {
    if (value == null) return MediaSource.unknown;
    return MediaSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MediaSource.unknown,
    );
  }

  bool get supportsThumbnail =>
      this == MediaSource.device || this == MediaSource.picked;

  bool get hasFilesystemPath =>
      this == MediaSource.downloads ||
      this == MediaSource.documents ||
      this == MediaSource.picked;
}
