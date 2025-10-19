import 'package:flutter/material.dart';
import 'requesting_permission_widget.dart';

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
    if (isRequestingPermission) return const RequestingPermissionWidget();

    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error.withAlpha(5),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет доступа к медиафайлам',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Пожалуйста, предоставьте разрешение, чтобы продолжить.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.lock_open),
              label: const Text('Разрешить доступ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
