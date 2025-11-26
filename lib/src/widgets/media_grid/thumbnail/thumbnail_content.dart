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
  final bool hasError;

  const ThumbnailContent({
    super.key,
    required this.isLoading,
    required this.thumbnail,
    required this.colorScheme,
    required this.item,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingPlaceholder(colorScheme: colorScheme);
    }

    if (hasError) {
      return MediaPlaceholder(
        colorScheme: colorScheme,
        isVideo: item.type == 'video',
        showError: true,
      );
    }

    if (thumbnail != null) {
      return Image.memory(
        thumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return MediaPlaceholder(
            colorScheme: colorScheme,
            isVideo: item.type == 'video',
            showError: true,
          );
        },
      );
    }

    return MediaPlaceholder(
      colorScheme: colorScheme,
      isVideo: item.type == 'video',
    );
  }
}
