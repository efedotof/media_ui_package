import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:media_ui_package/media_ui_package.dart';

class FullScreenMediaLoader {
  static Future<void> loadFullImage({
    required DeviceMediaLibrary mediaLibrary,
    required MediaItem item,
    required Map<String, Uint8List?> cache,
    required VoidCallback onLoaded,
  }) async {
    if (cache.containsKey(item.id)) return;

    try {
      final imageData = await mediaLibrary.getThumbnail(
        mediaId: item.id,
        mediaType: item.type,
        width: 1080,
        height: 1080,
      );

      if (imageData != null) {
        cache[item.id] = imageData;
        onLoaded();
      }
    } catch (e) {
      debugPrint('Error loading full image: $e');
    }
  }
}
