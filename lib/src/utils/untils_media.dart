import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class UntilsMedia {
  final mediaLibrary = DeviceMediaLibrary();

  Future<Uint8List?> getFileBytes(String uri) async {
    try {
      final bytes = await mediaLibrary.getFileBytes(uri);
      return bytes;
    } catch (e) {
      debugPrint('Error reading file by URI: $e');
      return null;
    }
  }
}