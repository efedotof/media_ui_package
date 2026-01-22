import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

import 'media_picker_widget.dart';

class MediaPickerUI extends StatefulWidget {
  final Widget child;
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onFilesSelected;
  final bool showPickButton;
  final bool enableDragDrop;
  final MediaPickerConfig? config;

  const MediaPickerUI({
    super.key,
    required this.child,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onFilesSelected,
    this.showPickButton = true,
    this.enableDragDrop = true,
    this.config,
  });

  @override
  State<MediaPickerUI> createState() => _MediaPickerUIState();
}

class _MediaPickerUIState extends State<MediaPickerUI> {
  final List<MediaItem> _selectedFiles = [];
  final GlobalKey<MediaPickerWidgetState> _pickerWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedFiles.addAll(widget.initialSelection);
  }

  Future<void> pickFiles() async {
    if (_pickerWidgetKey.currentState != null) {
      await _pickerWidgetKey.currentState!.pickFiles();
    }
  }

  Future<void> _handleSelectedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    setState(() {
      _selectedFiles.clear();
      _selectedFiles.addAll(files);
    });

    widget.onFilesSelected?.call(_selectedFiles);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FileSelectionDialog(
        selectedFiles: _selectedFiles,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        onClearAll: () {
          setState(() {
            _selectedFiles.clear();
          });
          Navigator.of(context).pop(false);
        },
        onItemRemoved: (file) {
          setState(() {
            _selectedFiles.remove(file);
          });
          if (_selectedFiles.isEmpty) {
            Navigator.of(context).pop(false);
          }
        },
      ),
    );

    if (confirmed == true && _selectedFiles.isNotEmpty) {
      widget.onFilesSelected?.call(_selectedFiles);
      _showMediaGrid();
    }
  }

  void _showMediaGrid() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: MediaPickerScreen(
          initialSelection: _selectedFiles,
          maxSelection: widget.maxSelection,
          allowMultiple: widget.allowMultiple,
          showVideos: widget.showVideos,
          onSelectionChanged: (files) {
            if (!mounted) return;
            setState(() {
              _selectedFiles.clear();
              _selectedFiles.addAll(files);
            });
          },
          config: widget.config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaPickerWidget(
      key: _pickerWidgetKey,
      initialSelection: _selectedFiles,
      maxSelection: widget.maxSelection,
      allowMultiple: widget.allowMultiple,
      showVideos: widget.showVideos,
      onSelectionChanged: (files) {
        if (!mounted) return;
        setState(() {
          _selectedFiles.clear();
          _selectedFiles.addAll(files);
        });
      },
      onConfirmed: _handleSelectedFiles,
      enableDragDrop: widget.enableDragDrop,
      config: widget.config,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),

          if (widget.showPickButton)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: pickFiles,
                child: const Icon(Icons.add_photo_alternate),
              ),
            ),
        ],
      ),
    );
  }
}
