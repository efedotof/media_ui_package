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
          duration: const Duration(milliseconds: 150),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              width: 1.8,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: isSelected
                ? Center(
                    key: const ValueKey(true),
                    child: Text(
                      '$selectionIndex',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey(false)),
          ),
        ),
      ),
    );
  }
}
