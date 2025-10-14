import 'package:flutter/material.dart';

class MediaGridEmptyWidget extends StatelessWidget {
  const MediaGridEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 64,
            color: colorScheme.onSurface.withAlpha(3),
          ),
          const SizedBox(height: 16),
          Text(
            'No media found',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
