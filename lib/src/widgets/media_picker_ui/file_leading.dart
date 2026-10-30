import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/file_bytes_cache.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/widgets/media_picker_ui/fallback_leading.dart';
import 'package:media_ui_package/src/widgets/media_picker_ui/preview_leading.dart';

class FileLeading extends StatelessWidget {
  final MediaItem item;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final int maxBytes;

  const FileLeading({
    super.key,
    required this.item,
    required this.fallbackColor,
    required this.fallbackIcon,
    required this.maxBytes,
  });

  bool get _canPreview =>
      item.type == 'image' &&
      item.size > 0 &&
      item.size <= maxBytes &&
      item.uri.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_canPreview) {
      return FallbackLeading(
        fallbackColor: fallbackColor,
        fallbackIcon: fallbackIcon,
      );
    }

    final cached = FileBytesCache.cached(item.uri);
    if (cached != null) return PreviewLeading(bytes: cached);

    return FutureBuilder<Uint8List?>(
      future: FileBytesCache.load(item.uri),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes != null && bytes.length <= maxBytes) {
          return PreviewLeading(bytes: bytes);
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fallbackColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return FallbackLeading(
          fallbackColor: fallbackColor,
          fallbackIcon: fallbackIcon,
        );
      },
    );
  }
}
