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
    try {
      debugPrint(
        'Loading media from device library: type=$type, limit=$limit, offset=$offset',
      );

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
    } catch (e) {
      debugPrint('Error in loadMedia: $e');
      return null;
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
    MediaGridController controller,
    MediaItem item,
  ) async {
    if (controller.thumbnailCompleters.containsKey(item.id)) return;

    final completer = Completer<Uint8List?>();
    controller.thumbnailCompleters[item.id] = completer;

    try {
      debugPrint('Loading thumbnail for: ${item.id}, type: ${item.type}');

      Uint8List? thumbnail;

      if (controller.thumbnailBuilder != null) {
        thumbnail = await controller.thumbnailBuilder!(item);
      } else {
        thumbnail = await controller.mediaLibrary.getThumbnail(
          mediaId: item.id,
          mediaType: item.type,
          width: 200,
          height: 200,
        );
      }

      if (thumbnail != null) {
        debugPrint('Thumbnail loaded successfully: ${thumbnail.length} bytes');
        controller.thumbnailCache[item.id] = thumbnail;
      } else {
        debugPrint('Thumbnail is null for: ${item.id}');
      }

      completer.complete(thumbnail);
    } catch (e) {
      debugPrint('Error loading thumbnail for ${item.id}: $e');
      completer.complete(null);
    } finally {
      controller.thumbnailCompleters.remove(item.id);
    }
  }

  static Future<Uint8List?> getThumbnailFuture(
    MediaGridController controller,
    MediaItem item,
  ) async {
    if (controller.thumbnailCache.containsKey(item.id)) {
      return controller.thumbnailCache[item.id];
    }

    if (controller.thumbnailCompleters.containsKey(item.id)) {
      return await controller.thumbnailCompleters[item.id]!.future;
    }

    _loadThumbnail(controller, item);
    return await controller.thumbnailCompleters[item.id]?.future;
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
