import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'media_grid_controller.dart';

class MediaGridLoader {
  static Future<List<Map<String, dynamic>>?> loadMedia({
    required DeviceMediaLibrary mediaLibrary,
    required MediaType type,
    required int limit,
    required int offset,
    required String? albumId,
  }) async {
    switch (type) {
      case MediaType.images:
        return await mediaLibrary.getImages(
          limit: limit,
          offset: offset,
          albumId: albumId,
        );
      case MediaType.videos:
        return await mediaLibrary.getVideos(
          limit: limit,
          offset: offset,
          albumId: albumId,
        );
      case MediaType.all:
        return await mediaLibrary.getAllMedia(
          limit: limit,
          offset: offset,
          albumId: albumId,
        );
    }
  }

  static void preloadThumbnails(
    MediaGridController controller,
    List<MediaItem> mediaItems,
  ) {
    for (final item in mediaItems) {
      if (!controller.thumbnailCache.containsKey(item.id) &&
          !controller.thumbnailCompleters.containsKey(item.id)) {
        _loadThumbnail(controller, item);
      }
    }
  }

  static Future<void> _loadThumbnail(
    MediaGridController c,
    MediaItem item,
  ) async {
    if (c.thumbnailCompleters.containsKey(item.id)) return;

    final completer = Completer<Uint8List?>();
    c.thumbnailCompleters[item.id] = completer;

    try {
      final thumb =
          await (c.thumbnailBuilder?.call(item) ??
              c.mediaLibrary.getThumbnail(
                mediaId: item.id,
                mediaType: item.type,
                width: 200,
                height: 200,
              ));
      if (thumb != null) c.thumbnailCache[item.id] = thumb;
      completer.complete(thumb);
    } catch (_) {
      completer.complete(null);
    } finally {
      c.thumbnailCompleters.remove(item.id);
    }
  }

  static Future<Uint8List?> getThumbnailFuture(
    MediaGridController c,
    MediaItem item,
  ) async {
    if (c.thumbnailCache.containsKey(item.id)) return c.thumbnailCache[item.id];
    if (c.thumbnailCompleters.containsKey(item.id)) {
      return await c.thumbnailCompleters[item.id]!.future;
    }
    _loadThumbnail(c, item);
    return await c.thumbnailCompleters[item.id]?.future;
  }

  // --- UI placeholders ---

  static Widget errorWidget(
    MediaPickerTheme theme,
    VoidCallback retry,
  ) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: theme.secondaryTextColor),
        const SizedBox(height: 16),
        Text(
          'Permission Required',
          style: TextStyle(
            color: theme.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This app needs access to your photos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.secondaryTextColor),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: retry,
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          child: const Text(
            'Grant Permission',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  static Widget loadingWidget(MediaPickerTheme theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: theme.primaryColor),
        const SizedBox(height: 16),
        Text(
          'Loading media...',
          style: TextStyle(color: theme.secondaryTextColor),
        ),
      ],
    ),
  );

  static Widget emptyWidget(MediaPickerTheme theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_library, size: 64, color: theme.secondaryTextColor),
        const SizedBox(height: 16),
        Text('No media found', style: TextStyle(color: theme.textColor)),
      ],
    ),
  );
}
