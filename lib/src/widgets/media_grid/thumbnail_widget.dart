import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class ThumbnailWidget extends StatelessWidget {
  final VoidCallback onThumbnailTap; // Колбэк для нажатия на миниатюру
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
    Widget child;

    if (thumbnail != null) {
      child = FadeInImage(
        placeholder: MemoryImage(Uint8List(0)),
        image: MemoryImage(thumbnail!),
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        imageErrorBuilder: (_, __, ___) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            item.type == 'video' ? Icons.videocam : Icons.photo,
            color: colorScheme.onSurface.withAlpha(3),
            size: 28,
          ),
        ),
      );
    } else if (isLoading) {
      child = Container(
        color: colorScheme.surface,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    } else {
      child = Container(
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          item.type == 'video' ? Icons.videocam : Icons.photo,
          color: colorScheme.onSurface.withAlpha(3),
          size: 28,
        ),
      );
    }

    return GestureDetector(
      onTap: onThumbnailTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (!isLoading && thumbnail == null)
            Positioned(
              bottom: 6,
              right: 6,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.refresh,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: onRetryLoad,
              ),
            ),
        ],
      ),
    );
  }
}
