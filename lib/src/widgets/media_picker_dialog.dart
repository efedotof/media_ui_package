import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'media_grid.dart';

class MediaPickerDialog extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final MediaPickerTheme theme;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;

  const MediaPickerDialog({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.theme = const MediaPickerTheme(),
    this.onSelectionChanged,
    this.onConfirmed,
  });

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
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

  void _cancelSelection() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.theme.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.theme.appBarColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.theme.borderRadius),
                  topRight: Radius.circular(widget.theme.borderRadius),
                ),
                border: Border(
                  bottom: BorderSide(color: widget.theme.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select Media',
                    style: TextStyle(
                      color: widget.theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.allowMultiple)
                    Text(
                      '${_selectedItems.length}/${widget.maxSelection}',
                      style: TextStyle(
                        color: widget.theme.secondaryTextColor,
                      ),
                    ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelSelection,
                    color: widget.theme.textColor,
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
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.theme.appBarColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.theme.borderRadius),
                  bottomRight: Radius.circular(widget.theme.borderRadius),
                ),
                border: Border(
                  top: BorderSide(color: widget.theme.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _cancelSelection,
                      style: TextButton.styleFrom(
                        foregroundColor: widget.theme.textColor,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _selectedItems.isNotEmpty ? _confirmSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.allowMultiple
                          ? 'Select (${_selectedItems.length})'
                          : 'Select'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
