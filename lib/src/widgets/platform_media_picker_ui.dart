import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/widgets/file_selection_dialog/file_selection_dialog.dart';

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

  bool _dropActive = true;
  bool get _isWeb => kIsWeb;
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  void initState() {
    super.initState();
    _selectedFiles.addAll(widget.initialSelection);
  }

  Future<void> _handleDroppedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    setState(() => _dropActive = false);

    await _handleSelectedFiles(files);

    if (mounted) {
      setState(() => _dropActive = true);
    }
  }

  Future<void> _handleSelectedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(files);
    });

    widget.onSelectionChanged?.call(_selectedFiles);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FileSelectionDialog(
        selectedFiles: _selectedFiles,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        onClearAll: () {
          if (!mounted) return;
          setState(() => _selectedFiles.clear());
          Navigator.of(context).pop(false);
        },
        onItemRemoved: (file) {
          if (!mounted) return;
          setState(() => _selectedFiles.remove(file));
          if (_selectedFiles.isEmpty) {
            Navigator.of(context).pop(false);
          }
        },
      ),
    );

    if (confirmed == true && _selectedFiles.isNotEmpty) {
      widget.onConfirmed?.call(_selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child ?? Container();

    if (widget.enableDragDrop && (_isWeb || _isDesktop) && _dropActive) {
      return UniversalDropZone(
        onFilesDropped: _handleDroppedFiles,
        allowedExtensions: widget.allowedExtensions,
        enabled: true,
        overlayText: S.of(context).dropFilesToAddMedia,
        showOverlay: true,
        child: child,
      );
    }

    return child;
  }
}
