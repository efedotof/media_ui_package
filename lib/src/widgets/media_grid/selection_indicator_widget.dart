import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class SelectionIndicatorWidget extends StatelessWidget {
  const SelectionIndicatorWidget({
    super.key,
    required this.config,
    required this.colorScheme,
    required this.onSelectionTap,
    required this.isSelected,
    required this.selectionIndex,
  });
  final MediaPickerConfig config;
  final ColorScheme colorScheme;
  final VoidCallback onSelectionTap;
  final bool isSelected;
  final int selectionIndex;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 6,
      child: GestureDetector(
        onTap: onSelectionTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected
                ? config.selectedColor
                : Colors.white.withAlpha(9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? config.selectedColor : Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: isSelected
              ? Center(
                  child: Text(
                    '$selectionIndex',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Icon(
                  Icons.circle_outlined,
                  size: 20,
                  color: Colors.black.withAlpha(6),
                ),
        ),
      ),
    );
  }
}
