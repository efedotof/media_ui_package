import 'package:flutter/material.dart';
import 'package:media_ui_package/src/widgets/media_grid/requesting_permission_widget.dart';

class MediaGridErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isRequestingPermission;

  const MediaGridErrorWidget({
    super.key,
    required this.onRetry,
    required this.isRequestingPermission,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isRequestingPermission) {
      return RequestingPermissionWidget();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.onSurface.withAlpha(3),
          ),
          const SizedBox(height: 16),
          Text(
            'Permission Required',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This app needs access to your photos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withAlpha(6)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}
