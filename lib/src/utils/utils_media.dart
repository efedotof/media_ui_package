import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/upload_media_request.dart';

class UtilsMedia {
  final DeviceMediaLibrary mediaLibrary = DeviceMediaLibrary();

  Future<Uint8List?> getFileBytes(String uri) async {
    try {
      if (uri.startsWith('data:')) {
        return _getBytesFromDataUri(uri);
      } else if (uri.startsWith('file://')) {
        return await _getBytesFromFileUri(uri);
      } else if (uri.startsWith('http://') || uri.startsWith('https://')) {
        return await _getBytesFromNetwork(uri);
      } else if (uri.startsWith('blob:')) {
        return await _getBytesFromBlobUrl(uri);
      } else if (uri.startsWith('content://')) {
        return await mediaLibrary.getFileBytes(uri);
      } else {
        try {
          final file = File(uri);
          if (await file.exists()) {
            return await file.readAsBytes();
          }
        } catch (e) {
          debugPrint('Error reading file directly: $e');
        }

        return await mediaLibrary.getFileBytes(uri);
      }
    } catch (e) {
      debugPrint('Error reading file by URI: $e');
      return null;
    }
  }

  Future<Uint8List?> _getBytesFromDataUri(String dataUri) async {
    try {
      if (!dataUri.startsWith('data:')) return null;

      final commaIndex = dataUri.indexOf(',');
      if (commaIndex == -1) return null;

      final data = dataUri.substring(commaIndex + 1);
      final isBase64 = dataUri.substring(0, commaIndex).endsWith(';base64');

      if (isBase64) {
        return base64.decode(data);
      } else {
        return Uint8List.fromList(utf8.encode(Uri.decodeFull(data)));
      }
    } catch (e) {
      debugPrint('Error parsing data URI: $e');
      return null;
    }
  }

  Future<Uint8List?> _getBytesFromFileUri(String fileUri) async {
    try {
      if (kIsWeb) {
        return null;
      }

      final uri = Uri.parse(fileUri);
      String path = uri.toFilePath(windows: Platform.isWindows);

      if (Platform.isWindows && path.startsWith('/') && path.length > 1) {
        if (path[2] == ':') {
          path = path.substring(1);
        }
      }

      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading file URI: $e');
      return null;
    }
  }

  Future<Uint8List?> _getBytesFromNetwork(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await response.fold<BytesBuilder>(
          BytesBuilder(),
          (builder, data) => builder..add(data),
        );
        return bytes.takeBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading from network: $e');
      return null;
    }
  }

  Future<Uint8List?> _getBytesFromBlobUrl(String blobUrl) async {
    try {
      final bytes = await mediaLibrary.getFileBytes(blobUrl);
      return bytes;
    } catch (e) {
      debugPrint('Error reading blob URL: $e');
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
        if (!kIsWeb) {
          final path = uri.replaceFirst('file://', '');
          final file = File(path);
          if (await file.exists()) {
            return uri;
          }
        }
        return null;
      } else if (uri.startsWith('data:')) {
        return uri;
      } else if (uri.startsWith('blob:')) {
        return uri;
      } else {
        if (!kIsWeb) {
          final file = File(uri);
          if (await file.exists()) {
            return 'file://$uri';
          }
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

        final fileBytes = await getFileBytes(uri);

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

  Future<UploadMediaRequest?> createUploadRequest(MediaItem mediaItem) async {
    try {
      final bytes = await getFileBytes(mediaItem.uri);
      if (bytes == null) return null;

      return UploadMediaRequest(
        bytes: bytes,
        fileName: mediaItem.name,
        mimeType: _getMimeTypeFromMediaItem(mediaItem),
      );
    } catch (e) {
      debugPrint('Error creating upload request: $e');
      return null;
    }
  }

  String? _getMimeTypeFromMediaItem(MediaItem item) {
    final fileName = item.name.toLowerCase();
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (fileName.endsWith('.png')) {
      return 'image/png';
    } else if (fileName.endsWith('.gif')) {
      return 'image/gif';
    } else if (fileName.endsWith('.webp')) {
      return 'image/webp';
    } else if (fileName.endsWith('.mp4')) {
      return 'video/mp4';
    } else if (fileName.endsWith('.mov')) {
      return 'video/quicktime';
    } else if (fileName.endsWith('.avi')) {
      return 'video/x-msvideo';
    } else if (fileName.endsWith('.mkv')) {
      return 'video/x-matroska';
    } else if (fileName.endsWith('.webm')) {
      return 'video/webm';
    } else if (fileName.endsWith('.pdf')) {
      return 'application/pdf';
    } else if (item.type == 'video') {
      return 'video/mp4';
    } else if (item.type == 'image') {
      return 'image/jpeg';
    }
    return null;
  }

  String getFileNameFromUri(String uri) {
    try {
      if (uri.startsWith('data:')) {
        final parts = uri.split(';');
        if (parts.isNotEmpty && parts[0].contains('image/')) {
          final type = parts[0].replaceFirst('data:image/', '');
          return 'image_${DateTime.now().millisecondsSinceEpoch}.${type.split('/').last}';
        }
        return 'file_${DateTime.now().millisecondsSinceEpoch}';
      } else if (uri.startsWith('blob:')) {
        return 'blob_${DateTime.now().millisecondsSinceEpoch}';
      } else if (uri.startsWith('content://')) {
        final segments = uri.split('/');
        if (segments.length > 1) {
          return segments.last;
        }
      } else {
        final uriObj = Uri.parse(uri);
        final pathSegments = uriObj.pathSegments;
        if (pathSegments.isNotEmpty) {
          return pathSegments.last;
        }
      }
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
