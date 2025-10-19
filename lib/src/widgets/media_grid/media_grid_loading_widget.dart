import 'package:flutter/material.dart';
import 'requesting_permission_widget.dart';

class MediaGridLoadingWidget extends StatelessWidget {
  final bool isRequestingPermission;

  const MediaGridLoadingWidget({
    super.key,
    required this.isRequestingPermission,
  });

  @override
  Widget build(BuildContext context) {
    if (isRequestingPermission) return const RequestingPermissionWidget();

    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Загрузка медиа...',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
