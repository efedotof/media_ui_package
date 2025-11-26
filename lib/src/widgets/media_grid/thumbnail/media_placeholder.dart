import 'package:flutter/material.dart';

class MediaPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isVideo;
  final bool showError;

  const MediaPlaceholder({
    super.key,
    required this.colorScheme,
    required this.isVideo,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo ? Icons.videocam : Icons.photo,
            color: showError
                ? colorScheme.error
                : colorScheme.onSurface.withAlpha(150),
            size: 28,
          ),
          if (showError) ...[
            const SizedBox(height: 4),
            Icon(Icons.error_outline, color: colorScheme.error, size: 16),
          ],
        ],
      ),
    );
  }
}
