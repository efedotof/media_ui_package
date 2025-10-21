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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surface.withAlpha(9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          isVideo ? Icons.videocam_rounded : Icons.photo_rounded,
          color: colorScheme.onSurface.withAlpha(5),
          size: 36,
        ),
      ),
    );
  }
}
