import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class PlatformMediaPickerUI extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;
  final Widget? child;
  final bool enableDragDrop;
  final List<String> allowedExtensions;
  final MediaPickerConfig? config;

  const PlatformMediaPickerUI({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.child,
    this.enableDragDrop = true,
    this.allowedExtensions = const [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.mp4',
      '.mov',
    ],
    this.config,
  });

  @override
  State<PlatformMediaPickerUI> createState() => _PlatformMediaPickerUIState();
}

class _PlatformMediaPickerUIState extends State<PlatformMediaPickerUI> {
  final List<MediaItem> _selectedFiles = [];
  final DeviceMediaLibrary _mediaLibrary = DeviceMediaLibrary();

  bool get _isWeb => kIsWeb;
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  void initState() {
    super.initState();
    _selectedFiles.addAll(widget.initialSelection);
  }

  Future<void> _pickFiles() async {
    if (_isWeb || _isDesktop) {
      final result = await _mediaLibrary.pickFiles(
        multiple: widget.allowMultiple,
        allowedFileTypes: widget.allowedExtensions,
      );

      if (result != null && result.isNotEmpty) {
        final mediaItems = result.map((file) {
          return MediaItem(
            id:
                file['id']?.toString() ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            name: file['name']?.toString() ?? 'Unknown',
            uri: file['uri']?.toString() ?? file['filePath']?.toString() ?? '',
            dateAdded: DateTime.now().millisecondsSinceEpoch,
            size: file['size'] is int ? file['size'] : 0,
            width: file['width'] is int ? file['width'] : 0,
            height: file['height'] is int ? file['height'] : 0,
            albumId: file['albumId']?.toString() ?? '',
            albumName: file['albumName']?.toString() ?? '',
            type: file['type']?.toString() ?? 'unknown',
            duration: file['duration'] is int ? file['duration'] : 0,
          );
        }).toList();

        _handleSelectedFiles(mediaItems);
      }
    } else {
      if (!mounted) return;
      final result = await showDialog<List<MediaItem>>(
        context: context,
        builder: (context) => MediaPickerBottomSheet(
          initialSelection: _selectedFiles,
          maxSelection: widget.maxSelection,
          allowMultiple: widget.allowMultiple,
          showVideos: widget.showVideos,
          onConfirmed: (files) {
            Navigator.of(context).pop(files);
          },
          config: widget.config,
        ),
      );

      if (result != null && result.isNotEmpty) {
        _handleSelectedFiles(result);
      }
    }
  }

  Future<void> _handleSelectedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    setState(() {
      _selectedFiles.clear();
      _selectedFiles.addAll(files);
    });

    widget.onSelectionChanged?.call(_selectedFiles);

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FileSelectionDialog(
        selectedFiles: _selectedFiles,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        onClearAll: () {
          if (!mounted) return;
          setState(() {
            _selectedFiles.clear();
          });
          Navigator.of(context).pop(false);
        },
        onItemRemoved: (file) {
          if (!mounted) return;
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
      widget.onConfirmed?.call(_selectedFiles);
      _showMediaGrid();
    }
  }

  void _showMediaGrid() {
    if (!mounted) return;
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

  Future<void> _handleDroppedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    if (!widget.allowMultiple && files.isNotEmpty) {
      _handleSelectedFiles([files.first]);
    } else if (widget.allowMultiple &&
        _selectedFiles.length + files.length <= widget.maxSelection) {
      _handleSelectedFiles([..._selectedFiles, ...files]);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum ${widget.maxSelection} files allowed'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child ?? Container();

    if (widget.enableDragDrop && (_isWeb || _isDesktop)) {
      return UniversalDropZone(
        onFilesDropped: _handleDroppedFiles,
        allowedExtensions: widget.allowedExtensions,
        enabled: true,
        overlayText: 'Drop files to add media',
        showOverlay: true,
        child: child,
      );
    }

    return child;
  }

  void pickFiles() => _pickFiles();
}
