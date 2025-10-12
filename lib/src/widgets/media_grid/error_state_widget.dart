import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.item,
    required this.onRetryLoad,
    required this.colorScheme,
  });
  final MediaItem item;
  final VoidCallback onRetryLoad;
  final ColorScheme colorScheme;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetryLoad,
      child: Container(
        color: colorScheme.surface.withAlpha(2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.type == 'video' ? Icons.videocam : Icons.photo,
                color: colorScheme.onSurface.withAlpha(3),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Retry',
                style: TextStyle(
                  color: colorScheme.onSurface.withAlpha(3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
