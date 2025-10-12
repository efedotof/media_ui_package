import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/media_item.dart';

import 'thumbnail_content.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({
    super.key,
    required this.onThumbnailTap,
    required this.colorScheme,
    required this.isLoading,
    required this.item,
    required this.onRetryLoad,
  });
  final VoidCallback onThumbnailTap;
  final ColorScheme colorScheme;
  final bool isLoading;
  final MediaItem item;
  final VoidCallback onRetryLoad;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onThumbnailTap,
      child: Container(
        color: colorScheme.surface.withAlpha(1),
        child: ThumbnailContent(
          isLoading: isLoading,
          colorScheme: colorScheme,
          onRetryLoad: onRetryLoad,
          item: item,
        ),
      ),
    );
  }
}
