import 'package:flutter/material.dart';

class SelectionOverlayMediaPickerUi extends StatelessWidget {
  final Color color;

  const SelectionOverlayMediaPickerUi({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.25),
      child: const Center(
        child: Icon(Icons.check, color: Colors.white, size: 32),
      ),
    );
  }
}
