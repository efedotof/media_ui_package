import 'dart:typed_data';

import 'package:device_media_library/device_media_library.dart';

class MediaThumbnailCache {
  MediaThumbnailCache._();

  static final Map<String, Uint8List?> _cache = {};
  static final Map<String, Future<Uint8List?>> _pending = {};
  static final DeviceMediaLibrary _lib = DeviceMediaLibrary();

  static Future<Uint8List?> load(
    String mediaId,
    String mediaType,
    int width,
    int height,
  ) async {
    final key = '$mediaId:${mediaType.toLowerCase()}:${width}x$height';
    if (_cache.containsKey(key)) return _cache[key];
    if (_pending.containsKey(key)) return _pending[key];

    final future = _lib.getThumbnail(
      mediaId: mediaId,
      mediaType: mediaType,
      width: width,
      height: height,
    );

    _pending[key] = future;
    try {
      final result = await future;
      _cache[key] = result;
      return result;
    } catch (_) {
      _cache[key] = null;
      return null;
    } finally {
      _pending.remove(key);
    }
  }

  static void clear() {
    _cache.clear();
    _pending.clear();
  }
}
