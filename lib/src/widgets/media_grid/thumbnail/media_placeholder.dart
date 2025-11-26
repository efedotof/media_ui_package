import 'package:flutter/material.dart';

class MediaPlaceholder extends StatelessWidget {
  final bool isVideo;
  final bool showError;

  const MediaPlaceholder({
    super.key,
    this.isVideo = false,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: showError
            ? Icon(Icons.error_outline, color: cs.error, size: 28)
            : Icon(
                isVideo ? Icons.videocam : Icons.photo,
                color: cs.onSurface,
                size: 28,
              ),
      ),
    );
  }
}
