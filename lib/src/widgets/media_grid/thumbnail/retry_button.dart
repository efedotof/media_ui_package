import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback onRetryLoad;

  const RetryButton({super.key, required this.onRetryLoad});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 6,
      right: 6,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(Icons.refresh, color: cs.primary, size: 20),
        onPressed: onRetryLoad,
      ),
    );
  }
}
