import 'package:flutter/material.dart';

class ErrorsWidget extends StatelessWidget {
  final Size screenSize;
  final String message;
  final VoidCallback? onRetry;

  const ErrorsWidget({
    super.key,
    required this.screenSize,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message.isNotEmpty ? message : 'Error',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              IconButton(
                icon: Icon(Icons.refresh, color: cs.primary),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
