import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onRetryLoad;

  const RetryButton({
    super.key,
    required this.colorScheme,
    required this.onRetryLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6,
      right: 6,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.refresh,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onPressed: onRetryLoad,
      ),
    );
  }
}
