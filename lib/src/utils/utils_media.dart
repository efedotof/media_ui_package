import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class UtilsMedia {
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

  Future<String?> getValidFilePath(String uri) async {
    try {
      if (uri.startsWith('content://')) {
        final bytes = await getFileBytes(uri);
        if (bytes != null) {
          return uri;
        }
        return null;
      } else if (uri.startsWith('file://')) {
        final path = uri.replaceFirst('file://', '');
        final file = File(path);
        if (await file.exists()) {
          return uri;
        }
        return null;
      } else {
        final file = File(uri);
        if (await file.exists()) {
          return 'file://$uri';
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error validating file path: $e');
      return null;
    }
  }

  Future<List<Uint8List?>> uploadsImages(List<String> filesPath) async {
    try {
      List<Uint8List?> filesBytes = [];

      for (var uri in filesPath) {
        final fileName = uri.split('/').last;
        debugPrint('Processing file: $fileName');

        Uint8List? fileBytes;

        if (uri.startsWith('content://')) {
          fileBytes = await getFileBytes(uri);
        } else if (uri.startsWith('file://')) {
          fileBytes = await getFileBytes(uri);
        } else {
          fileBytes = await getFileBytes(uri);
        }

        if (fileBytes != null) {
          debugPrint(
            'Successfully read file: $fileName, size: ${fileBytes.length} bytes',
          );
          filesBytes.add(fileBytes);
        } else {
          debugPrint('Failed to read file: $fileName');
          filesBytes.add(null);
        }
      }

      debugPrint('Total files processed: ${filesBytes.length}');
      return filesBytes;
    } catch (e) {
      debugPrint('Error in uploadsImages: $e');
      return List<Uint8List?>.filled(filesPath.length, null);
    }
  }
}
