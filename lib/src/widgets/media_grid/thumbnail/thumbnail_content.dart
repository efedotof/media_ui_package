import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'loading_placeholder.dart';
import 'media_placeholder.dart';

class ThumbnailContent extends StatelessWidget {
  final bool isLoading;
  final Uint8List? thumbnail;
  final ColorScheme colorScheme;
  final MediaItem item;

  const ThumbnailContent({
    super.key,
    required this.isLoading,
    required this.thumbnail,
    required this.colorScheme,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingPlaceholder(colorScheme: colorScheme);
    }

    if (thumbnail != null) {
      return AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: Image.memory(
          thumbnail!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => MediaPlaceholder(
            colorScheme: colorScheme,
            isVideo: item.type == 'video',
          ),
        ),
      );
    }

    return MediaPlaceholder(
      colorScheme: colorScheme,
      isVideo: item.type == 'video',
    );
  }
}
