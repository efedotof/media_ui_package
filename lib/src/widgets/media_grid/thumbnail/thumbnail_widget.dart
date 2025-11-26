import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'retry_button.dart';
import 'thumbnail_content.dart';

class ThumbnailWidget extends StatelessWidget {
  final VoidCallback onThumbnailTap;
  final MediaItem item;
  final bool isLoading;
  final Uint8List? thumbnail;
  final bool hasError;
  final VoidCallback onRetryLoad;

  const ThumbnailWidget({
    super.key,
    required this.onThumbnailTap,
    required this.item,
    required this.isLoading,
    required this.thumbnail,
    required this.onRetryLoad,
    this.hasError = false,
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
            item: item,
            hasError: hasError,
          ),
          if ((!isLoading && thumbnail == null) || hasError)
            RetryButton(onRetryLoad: onRetryLoad),
        ],
      ),
    );
  }
}
