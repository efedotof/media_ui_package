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

    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
      ),
    );
  }
}
