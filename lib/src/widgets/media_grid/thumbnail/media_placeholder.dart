import 'package:flutter/material.dart';

class MediaPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isVideo;

  const MediaPlaceholder({
    super.key,
    required this.colorScheme,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        isVideo ? Icons.videocam : Icons.photo,
        color: colorScheme.onSurface.withAlpha(150),
        size: 28,
      ),
    );
  }
}