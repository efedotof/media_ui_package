import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/widgets/file_selection_dialog/file_selection_dialog.dart';

class MediaPickerWidget extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MapEntry<MediaItem, Uint8List?>>)? onConfirmed;
  final Widget child;
  final bool enableDragDrop;
  final List<String> allowedExtensions;
  final MediaPickerConfig? config;

  const MediaPickerWidget({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    required this.child,
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
  MediaPickerWidgetState createState() => MediaPickerWidgetState();
}

class MediaPickerWidgetState extends State<MediaPickerWidget> {
  final List<MediaItem> _selectedFiles = [];
  final DeviceMediaLibrary _mediaLibrary = DeviceMediaLibrary();

  @override
  void initState() {
    super.initState();
    _selectedFiles.addAll(widget.initialSelection);
    DeviceMediaLibrary.ensureInitialized();
  }

  Future<void> pickFiles() async {
    final isWeb = kIsWeb;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    if (isWeb || isDesktop) {
      try {
        debugPrint('Opening file picker for ${isWeb ? 'Web' : 'Windows'}');

        final result = await _mediaLibrary.pickFiles(
          multiple: widget.allowMultiple,
          allowedFileTypes: widget.allowedExtensions,
        );

        if (result != null && result.isNotEmpty) {
          debugPrint('Got ${result.length} files from picker');

          final filesWithBytes = <MapEntry<MediaItem, Uint8List?>>[];

          for (final file in result) {
            final uri =
                file['uri']?.toString() ?? file['filePath']?.toString() ?? '';
            final name = file['name']?.toString() ?? 'Unknown';
            final size = file['size'] is int ? file['size'] : 0;
            final type = file['type']?.toString() ?? 'unknown';

            Uint8List? bytes;

            if (isDesktop && uri.startsWith('file://')) {
              try {
                final filePath = Uri.parse(
                  uri,
                ).toFilePath(windows: Platform.isWindows);
                final file = File(filePath);
                if (await file.exists()) {
                  bytes = await file.readAsBytes();
                  debugPrint('Read ${bytes.length} bytes from file: $filePath');
                }
              } catch (e) {
                debugPrint('Error reading file bytes: $e');
              }
            }

            final mediaItem = MediaItem(
              id:
                  file['id']?.toString() ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              name: name,
              uri: uri,
              dateAdded: DateTime.now().millisecondsSinceEpoch,
              size: size,
              width: file['width'] is int ? file['width'] : 0,
              height: file['height'] is int ? file['height'] : 0,
              albumId: file['albumId']?.toString() ?? '',
              albumName: file['albumName']?.toString() ?? '',
              type: type,
              duration: file['duration'] is int ? file['duration'] : 0,
            );

            filesWithBytes.add(MapEntry(mediaItem, bytes));
          }

          await _handleSelectedFilesWithBytes(filesWithBytes);
        }
      } catch (e) {
        debugPrint('Error in pickFiles: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).failedToPickFilesE),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      if (!mounted) return;

      await MediaPickerBottomSheet.open(
        context: context,
        initialSelection: _selectedFiles,
        maxSelection: widget.maxSelection,
        allowMultiple: widget.allowMultiple,
        showVideos: widget.showVideos,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        showSelectionIndicators: true,
        config: widget.config ?? const MediaPickerConfig(),
        mediaLibrary: _mediaLibrary,
        onConfirmedWithBytes: (filesWithBytes) {
          if (filesWithBytes.isEmpty) return;

          final result = filesWithBytes
              .map((e) => MapEntry(e.key, e.value))
              .toList(growable: false);

          if (widget.onConfirmed != null) {
            widget.onConfirmed!(result);
          }

          if (mounted) {
            setState(() {
              _selectedFiles.clear();
              _selectedFiles.addAll(filesWithBytes.map((e) => e.key).toList());
            });
            widget.onSelectionChanged?.call(_selectedFiles);
          }
        },
      );
    }
  }

  Future<void> _handleSelectedFilesWithBytes(
    List<MapEntry<MediaItem, Uint8List?>> filesWithBytes,
  ) async {
    if (!mounted) return;

    setState(() {
      _selectedFiles.clear();
      _selectedFiles.addAll(filesWithBytes.map((e) => e.key).toList());
    });

    widget.onSelectionChanged?.call(_selectedFiles);

    if (!mounted) return;

    final result = await showDialog<List<MapEntry<MediaItem, Uint8List?>>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FileSelectionDialog(
        selectedFiles: _selectedFiles,
        onConfirm: () {
          debugPrint("onConfirm: [MediaPickerWidget]");
          final confirmedFiles = filesWithBytes
              .where(
                (entry) =>
                    _selectedFiles.any((item) => item.id == entry.key.id),
              )
              .toList(growable: false);
          Navigator.of(context).pop(confirmedFiles);
        },
        onCancel: () {
          debugPrint("onCancel: [MediaPickerWidget]");
          Navigator.of(context).pop(<MapEntry<MediaItem, Uint8List?>>[]);
        },
        onClearAll: () {
          if (!mounted) return;
          setState(() {
            _selectedFiles.clear();
          });
          Navigator.of(context).pop(<MapEntry<MediaItem, Uint8List?>>[]);
          debugPrint("onClearAll: [MediaPickerWidget]");
        },
        onItemRemoved: (file) {
          if (!mounted) return;
          setState(() {
            _selectedFiles.remove(file);
          });
          if (_selectedFiles.isEmpty) {
            Navigator.of(context).pop(<MapEntry<MediaItem, Uint8List?>>[]);
            debugPrint("onClearAll: [onItemRemoved]");
          }
        },
      ),
    );

    if (result != null && result.isNotEmpty) {
      debugPrint('Confirming with ${result.length} files and bytes');
      if (widget.onConfirmed != null) {
        widget.onConfirmed!(result);
      }
    }
  }

  Future<void> _handleDroppedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    if (!widget.allowMultiple && files.isNotEmpty) {
      await _handleSelectedFiles([files.first]);
    } else if (widget.allowMultiple &&
        _selectedFiles.length + files.length <= widget.maxSelection) {
      await _handleSelectedFiles([..._selectedFiles, ...files]);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).maximumWidgetmaxselectionFilesAllowed),
            duration: const Duration(seconds: 2),
          ),
        );
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

    final result = await showDialog<List<MapEntry<MediaItem, Uint8List?>>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FileSelectionDialog(
        selectedFiles: _selectedFiles,
        onConfirm: () {
          debugPrint("onConfirm: [MediaPickerWidget]");
          final confirmedFiles = _selectedFiles
              .map((item) => MapEntry<MediaItem, Uint8List?>(item, null))
              .toList(growable: false);
          Navigator.of(context).pop(confirmedFiles);
        },
        onCancel: () {
          debugPrint("onCancel: [MediaPickerWidget]");
          Navigator.of(context).pop(<MapEntry<MediaItem, Uint8List?>>[]);
        },
        onClearAll: () {
          if (!mounted) return;
          setState(() {
            _selectedFiles.clear();
          });
          Navigator.of(context).pop(<MapEntry<MediaItem, Uint8List?>>[]);
          debugPrint("onClearAll: [MediaPickerWidget]");
        },
        onItemRemoved: (file) {
          if (!mounted) return;
          setState(() {
            _selectedFiles.remove(file);
          });
          if (_selectedFiles.isEmpty) {
            Navigator.of(context).pop(<MapEntry<MediaItem, Uint8List?>>[]);
            debugPrint("onClearAll: [onItemRemoved]");
          }
        },
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (widget.onConfirmed != null) {
        widget.onConfirmed!(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    if (widget.enableDragDrop && (isWeb || isDesktop)) {
      return UniversalDropZone(
        onFilesDropped: _handleDroppedFiles,
        allowedExtensions: widget.allowedExtensions,
        enabled: true,
        overlayText: S.of(context).dropFilesToAddMedia,
        showOverlay: true,
        child: widget.child,
      );
    }
    return widget.child;
  }
}
