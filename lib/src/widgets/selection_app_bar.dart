import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final int maxSelection;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback? onBack;

  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.maxSelection,
    required this.onClear,
    required this.onDone,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    MediaPickerConfig.of(context);

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      title: selectedCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$selectedCount',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          : null,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      actions: [
        if (selectedCount > 0)
          IconButton(icon: const Icon(Icons.check), onPressed: onDone),
      ],
    );
  }
}
