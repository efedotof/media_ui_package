import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

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
}
