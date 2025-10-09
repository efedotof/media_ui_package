import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'media_grid/media_grid.dart';
import 'selection_app_bar.dart';

class MediaPickerScreen extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final MediaPickerTheme theme;
  final String title;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Future<Uint8List?> Function(MediaItem)? thumbnailBuilder;
  final String? albumId;
  final MediaType mediaType;

  const MediaPickerScreen({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.theme = const MediaPickerTheme(),
    this.title = 'Select Media',
    this.onSelectionChanged,
    this.thumbnailBuilder,
    this.albumId,
    this.mediaType = MediaType.all,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
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
        _selectedItems.removeWhere(
          (selectedItem) => selectedItem.id == item.id,
        );
      }
      widget.onSelectionChanged?.call(_selectedItems);
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedItems);
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
      widget.onSelectionChanged?.call(_selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: widget.theme.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: widget.theme.appBarColor,
          foregroundColor: widget.theme.textColor,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: SelectionAppBar(
          title: widget.title,
          selectedCount: _selectedItems.length,
          maxSelection: widget.maxSelection,
          theme: widget.theme,
          onClear: _clearSelection,
          onDone: _confirmSelection,
        ),
        body: MediaGrid(
          selectedItems: _selectedItems,
          onItemSelected: _onItemSelected,
          theme: widget.theme,
          showVideos: widget.showVideos,
          thumbnailBuilder: widget.thumbnailBuilder,
          albumId: widget.albumId,
          mediaType: widget.mediaType,
        ),
      ),
    );
  }
}
