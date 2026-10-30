import 'package:flutter/material.dart';

class FallbackLeading extends StatelessWidget {
  const FallbackLeading({
    super.key,
    required this.fallbackColor,
    required this.fallbackIcon,
  });
  final Color fallbackColor;
  final IconData fallbackIcon;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: fallbackColor.withValues(alpha: 0.15),
      child: Icon(fallbackIcon, color: fallbackColor),
    );
  }
}
