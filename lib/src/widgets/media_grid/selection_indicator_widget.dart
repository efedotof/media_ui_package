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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? config.selectedColor
                : colorScheme.surface.withAlpha(4),
            border: Border.all(
              color: isSelected ? config.selectedColor : Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: isSelected
                ? Center(
                    key: const ValueKey(true),
                    child: Text(
                      '$selectionIndex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.circle_outlined,
                    key: ValueKey(false),
                    size: 18,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
