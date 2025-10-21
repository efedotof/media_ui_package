import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'retry_button.dart';
import 'thumbnail_content.dart';

class ThumbnailWidget extends StatelessWidget {
  final VoidCallback onThumbnailTap;
  final ColorScheme colorScheme;
  final bool isLoading;
  final MediaItem item;
  final VoidCallback onRetryLoad;
  final Uint8List? thumbnail;

  const ThumbnailWidget({
    super.key,
    required this.onThumbnailTap,
    required this.colorScheme,
    required this.isLoading,
    required this.item,
    required this.onRetryLoad,
    required this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == 'video';

    return GestureDetector(
      onTap: onThumbnailTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ThumbnailContent(
              isLoading: isLoading,
              thumbnail: thumbnail,
              colorScheme: colorScheme,
              item: item,
            ),
            if (isVideo)
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            if (!isLoading && thumbnail == null)
              RetryButton(colorScheme: colorScheme, onRetryLoad: onRetryLoad),
          ],
        ),
      ),
    );
  }
}
