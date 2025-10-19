import 'package:flutter/material.dart';

class RequestingPermissionWidget extends StatelessWidget {
  const RequestingPermissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Запрос разрешения',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
