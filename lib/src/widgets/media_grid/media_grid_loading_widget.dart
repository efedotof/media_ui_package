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
    final theme = Theme.of(context);

    if (isRequestingPermission) {
      return RequestingPermissionWidget();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading media...',
            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(6)),
          ),
        ],
      ),
    );
  }
}
