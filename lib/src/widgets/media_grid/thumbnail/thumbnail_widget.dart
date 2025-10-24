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
    return GestureDetector(
      onTap: onThumbnailTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ThumbnailContent(
            isLoading: isLoading,
            thumbnail: thumbnail,
            colorScheme: colorScheme,
            item: item,
          ),
          if (!isLoading && thumbnail == null)
            RetryButton(colorScheme: colorScheme, onRetryLoad: onRetryLoad),
        ],
      ),
    );
  }
}
