import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'media_grid.dart';

class MediaPickerBottomSheet extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final MediaPickerTheme theme;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const MediaPickerBottomSheet({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.theme = const MediaPickerTheme(),
    this.onSelectionChanged,
    this.onConfirmed,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.9,
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
    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.theme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.theme.secondaryTextColor.withAlpha(4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: widget.theme.borderColor.withAlpha(3)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Media',
                            style: TextStyle(
                              color: widget.theme.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.allowMultiple
                                ? 'Select up to ${widget.maxSelection} items'
                                : 'Select one item',
                            style: TextStyle(
                              color: widget.theme.secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedItems.isNotEmpty)
                      Row(
                        children: [
                          Text(
                            '${_selectedItems.length}/${widget.maxSelection}',
                            style: TextStyle(
                              color: widget.theme.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _clearSelection,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.theme.primaryColor.withAlpha(1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: widget.theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: MediaGrid(
                  selectedItems: _selectedItems,
                  onItemSelected: _onItemSelected,
                  theme: widget.theme,
                  showVideos: widget.showVideos,
                  scrollController: scrollController,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.theme.appBarColor,
                  border: Border(
                    top: BorderSide(
                        color: widget.theme.borderColor.withAlpha(3)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.theme.textColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: widget.theme.borderColor),
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
                                ? widget.theme.primaryColor
                                : widget.theme.primaryColor.withAlpha(4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedItems.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_selectedItems.length}',
                                    style: TextStyle(
                                      color: widget.theme.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(widget.allowMultiple ? 'Confirm' : 'Select'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
