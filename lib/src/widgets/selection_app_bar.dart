import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int selectedCount;
  final int maxSelection;
  final MediaPickerTheme theme;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback? onBack;

  const SelectionAppBar({
    super.key,
    required this.title,
    required this.selectedCount,
    required this.maxSelection,
    required this.theme,
    required this.onClear,
    required this.onDone,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: theme.appBarColor,
      foregroundColor: theme.textColor,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            selectedCount > 0
                ? '$selectedCount/$maxSelection selected'
                : 'Select up to $maxSelection items',
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
          ),
        ],
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.textColor.withAlpha(1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 20),
        ),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      actions: [
        if (selectedCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$selectedCount',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              label: const Text('Done'),
            ),
          ),
        const SizedBox(width: 12),
      ],
    );
  }
}
