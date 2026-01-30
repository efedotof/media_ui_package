import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/upload_media_request.dart';
import 'package:media_ui_package/src/widgets/file_selection_dialog/file_selection_dialog.dart';
import 'package:media_ui_package/src/widgets/media_picker_bottom_sheet.dart';

class MediaPickerWidget extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<UploadMediaRequest>)? onConfirmedWithRequests;
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
    this.onConfirmedWithRequests,
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
  final UtilsMedia _utilsMedia = UtilsMedia();

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
        debugPrint('Opening file picker for ${isWeb ? 'Web' : 'Desktop'}');

        final result = await _mediaLibrary.pickFiles(
          multiple: widget.allowMultiple,
          allowedFileTypes: widget.allowedExtensions,
        );

        if (result != null && result.isNotEmpty) {
          debugPrint('Got ${result.length} files from picker');

          final mediaItems = result.map((file) {
            return MediaItem(
              id:
                  file['id']?.toString() ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              name: file['name']?.toString() ?? 'Unknown',
              uri:
                  file['uri']?.toString() ?? file['filePath']?.toString() ?? '',
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

          await _handleSelectedFiles(mediaItems);
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
        onConfirmedWithRequests: (requests) {
          if (requests.isEmpty) return;

          if (widget.onConfirmedWithRequests != null) {
            widget.onConfirmedWithRequests!(requests);
          }
          if (mounted) {
            setState(() {
              _selectedFiles.clear();
              final mediaItems = requests
                  .map(
                    (req) => MediaItem(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: req.fileName,
                      uri: 'temp://${req.fileName}',
                      dateAdded: DateTime.now().millisecondsSinceEpoch,
                      size: req.bytes.length,
                      width: 0,
                      height: 0,
                      albumId: '',
                      albumName: '',
                      type: _getTypeFromFileName(req.fileName),
                    ),
                  )
                  .toList();
              _selectedFiles.addAll(mediaItems);
            });
            widget.onSelectionChanged?.call(_selectedFiles);
          }
        },
      );
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
      final requests = <UploadMediaRequest>[];
      for (final mediaItem in _selectedFiles) {
        try {
          final request = await _utilsMedia.createUploadRequest(mediaItem);
          if (request != null) {
            requests.add(request);
          }
        } catch (e) {
          debugPrint('Error creating upload request for ${mediaItem.name}: $e');
        }
      }

      if (requests.isNotEmpty && widget.onConfirmedWithRequests != null) {
        widget.onConfirmedWithRequests!(requests);
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

  String _getTypeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm')) {
      return 'video';
    }
    return 'image';
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
