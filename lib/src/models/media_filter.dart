import 'media_type.dart';

enum MediaFilter {
  all,
  image,
  video,
  audio,
  file;

  String? get typeString {
    switch (this) {
      case MediaFilter.all:
        return null;
      case MediaFilter.image:
        return 'image';
      case MediaFilter.video:
        return 'video';
      case MediaFilter.audio:
        return 'audio';
      case MediaFilter.file:
        return 'file';
    }
  }

  bool matches(String? itemType) {
    if (this == MediaFilter.all) return true;
    return itemType == typeString;
  }
}

extension MediaTypeToFilter on MediaType {
  MediaFilter toFilter() {
    switch (this) {
      case MediaType.all:
        return MediaFilter.all;
      case MediaType.images:
        return MediaFilter.image;
      case MediaType.videos:
        return MediaFilter.video;
    }
  }
}
