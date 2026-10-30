import 'package:flutter/material.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';

class SelectIndicator extends StatelessWidget {
  final bool selected;
  final bool compact;

  const SelectIndicator({
    super.key,
    required this.selected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = MediaPickerConfig.of(context);
    final size = compact ? 22.0 : 24.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? config.selectedColor : Colors.black26,
        border: Border.all(color: config.borderColor, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }
}
