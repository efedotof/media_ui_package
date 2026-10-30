import 'package:flutter/material.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final int totalCount;
  final String title;
  final bool multiSelect;
  final VoidCallback? onClose;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onConfirm;
  final String confirmLabel;

  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    this.title = 'Медиа',
    this.multiSelect = true,
    this.onClose,
    this.onSelectAll,
    this.onDeselectAll,
    this.onConfirm,
    this.confirmLabel = 'Готово',
  });

  bool get _isSelectionMode => selectedCount > 0;
  bool get _allSelected => totalCount > 0 && selectedCount == totalCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isSelectionMode) {
      return AppBar(
        title: Text(title),
        leading: onClose != null
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Закрыть',
                onPressed: onClose,
              )
            : null,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      );
    }

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Отменить выбор',
          onPressed: onDeselectAll ?? onClose,
        ),

        title: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Container(
                key: ValueKey<int>(selectedCount),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$selectedCount',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Flexible(
              child: Text(
                'Выбрано',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        actions: [
          if (multiSelect && (onSelectAll != null || onDeselectAll != null))
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Действия',
              onSelected: (value) {
                if (value == 'select_all' && onSelectAll != null) {
                  onSelectAll!();
                } else if (value == 'deselect_all' && onDeselectAll != null) {
                  onDeselectAll!();
                }
              },
              itemBuilder: (context) => [
                if (onSelectAll != null && !_allSelected)
                  const PopupMenuItem(
                    value: 'select_all',
                    child: Row(
                      children: [
                        Icon(Icons.select_all, size: 20),
                        SizedBox(width: 12),
                        Text('Выбрать всё'),
                      ],
                    ),
                  ),
                if (onDeselectAll != null)
                  const PopupMenuItem(
                    value: 'deselect_all',
                    child: Row(
                      children: [
                        Icon(Icons.deselect, size: 20),
                        SizedBox(width: 12),
                        Text('Снять выбор'),
                      ],
                    ),
                  ),
              ],
            ),

          if (onConfirm != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: FilledButton(
                    onPressed: _isSelectionMode ? onConfirm : null,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
