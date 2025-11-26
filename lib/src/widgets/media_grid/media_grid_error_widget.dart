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

    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
