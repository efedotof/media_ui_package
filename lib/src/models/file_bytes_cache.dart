import 'dart:typed_data';

import 'package:device_media_library/device_media_library.dart';
import 'package:flutter/foundation.dart';

class FileBytesCache {
  FileBytesCache._();

  static const int _maxCachedFiles = 30;
  static const int _maxBytesPerFile = 2 * 1024 * 1024;

  static final Map<String, Uint8List?> _cache = {};
  static final Map<String, Future<Uint8List?>> _pending = {};
  static final List<String> _order = [];

  static bool isCached(String uri) => _cache.containsKey(uri);

  static Uint8List? cached(String uri) {
    if (!_cache.containsKey(uri)) return null;
    _touch(uri);
    return _cache[uri];
  }

  static Future<Uint8List?> load(String uri) async {
    if (_cache.containsKey(uri)) {
      _touch(uri);
      return _cache[uri];
    }
    if (_pending.containsKey(uri)) {
      return _pending[uri]!;
    }
    final future = DeviceMediaLibrary().getFileBytes(uri);
    _pending[uri] = future;
    try {
      final bytes = await future;
      _store(uri, bytes);
      return bytes;
    } catch (e) {
      debugPrint('FileBytesCache error: $e');
      _store(uri, null);
      return null;
    } finally {
      _pending.remove(uri);
    }
  }

  static void _store(String uri, Uint8List? bytes) {
    final withinLimit = bytes == null || bytes.length <= _maxBytesPerFile;
    _cache[uri] = withinLimit ? bytes : null;
    _order.remove(uri);
    _order.add(uri);
    while (_order.length > _maxCachedFiles) {
      final old = _order.removeAt(0);
      _cache.remove(old);
    }
  }

  static void _touch(String uri) {
    _order.remove(uri);
    _order.add(uri);
  }

  static void clear() {
    _cache.clear();
    _pending.clear();
    _order.clear();
  }
}