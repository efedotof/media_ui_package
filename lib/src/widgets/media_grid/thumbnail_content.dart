import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'placeholder_widget.dart';
import 'error_state_widget.dart';

class ThumbnailContent extends StatelessWidget {
  const ThumbnailContent({
    super.key,
    this.thumbnail,
    required this.isLoading,
    required this.colorScheme,
    required this.onRetryLoad,
    required this.item,
  });
  final Uint8List? thumbnail;
  final bool isLoading;
  final ColorScheme colorScheme;
  final VoidCallback onRetryLoad;
  final MediaItem item;
  @override
  Widget build(BuildContext context) {
    if (thumbnail != null) {
      return Image.memory(
        thumbnail!,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        cacheWidth: 200,
        cacheHeight: 200,
      );
    }

    if (isLoading) {
      return PlaceholderWidget(colorScheme: colorScheme);
    }

    return ErrorStateWidget(
      item: item,
      onRetryLoad: onRetryLoad,
      colorScheme: colorScheme,
    );
  }
}
