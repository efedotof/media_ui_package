import 'dart:async';
import 'package:flutter/material.dart';

class MediaPickerBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String text;
  final String? actionLabel;
  final FutureOr<void> Function()? onAction;

  const MediaPickerBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: () => onAction!(), child: Text(actionLabel!)),
        ],
      ),
    );
  }
}