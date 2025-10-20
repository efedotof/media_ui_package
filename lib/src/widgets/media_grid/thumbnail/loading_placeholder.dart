import 'package:flutter/material.dart';

class LoadingPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;

  const LoadingPlaceholder({
    super.key,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surface,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}