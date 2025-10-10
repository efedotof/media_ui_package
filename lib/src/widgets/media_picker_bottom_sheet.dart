import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class MediaPickerBottomSheet extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final MediaPickerConfig? config;

  const MediaPickerBottomSheet({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.9,
    this.config,
  });

  @override
  State<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends State<MediaPickerBottomSheet> {
  late List<MediaItem> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelection);
  }

  void _onItemSelected(MediaItem item, bool selected) {
    setState(() {
      if (selected) {
        if (widget.allowMultiple &&
            _selectedItems.length < widget.maxSelection) {
          _selectedItems.add(item);
        } else if (!widget.allowMultiple) {
          _selectedItems = [item];
        }
      } else {
        _selectedItems.remove(item);
      }
      widget.onSelectionChanged?.call(_selectedItems);
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedItems);
    widget.onConfirmed?.call(_selectedItems);
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
      widget.onSelectionChanged?.call(_selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = widget.config ?? const MediaPickerConfig();

    return MediaPickerConfigScope(
      config: config,
      child: DraggableScrollableSheet(
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.minChildSize,
        maxChildSize: widget.maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withAlpha(3),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Media',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.allowMultiple
                                  ? 'Choose up to ${widget.maxSelection}'
                                  : 'Choose one',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withAlpha(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedItems.isNotEmpty) ...[
                        Text(
                          '${_selectedItems.length}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _clearSelection,
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            'Clear',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: MediaGrid(
                    selectedItems: _selectedItems,
                    onItemSelected: _onItemSelected,
                    showVideos: widget.showVideos,
                    scrollController: scrollController,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: colorScheme.outline.withAlpha(3),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedItems.isNotEmpty
                              ? _confirmSelection
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedItems.isNotEmpty
                                ? colorScheme.primary
                                : colorScheme.primary.withAlpha(4),
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedItems.isNotEmpty) ...[
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_selectedItems.length}',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              Text(widget.allowMultiple ? 'Confirm' : 'Select'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
