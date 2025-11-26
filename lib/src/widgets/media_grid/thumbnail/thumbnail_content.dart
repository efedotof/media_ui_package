import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'loading_placeholder.dart';
import 'media_placeholder.dart';

class ThumbnailContent extends StatelessWidget {
  final bool isLoading;
  final Uint8List? thumbnail;
  final MediaItem item;
  final bool hasError;

  const ThumbnailContent({
    super.key,
    required this.isLoading,
    required this.thumbnail,
    required this.item,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LoadingPlaceholder();

    if (hasError || thumbnail == null) {
      return MediaPlaceholder(
        isVideo: item.type == 'video',
        showError: hasError,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.memory(
        thumbnail!,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) =>
            MediaPlaceholder(isVideo: item.type == 'video', showError: true),
      ),
    );
  }
}
