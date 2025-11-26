import 'package:flutter/material.dart';

class RequestingPermissionWidget extends StatelessWidget {
  const RequestingPermissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
        strokeWidth: 2,
      ),
    );
  }
}
