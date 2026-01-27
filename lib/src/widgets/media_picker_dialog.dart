import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';

class MediaPickerDialog extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final bool showSelectionIndicators;
  final MediaPickerConfig config;
  final DeviceMediaLibrary mediaLibrary;
  final void Function(List<MapEntry<MediaItem, Uint8List?>>) onConfirmed;

  const MediaPickerDialog({
    super.key,
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    required this.showSelectionIndicators,
    required this.config,
    required this.mediaLibrary,
    required this.onConfirmed,
  });

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  late List<MediaItem> _selectedFiles;

  @override
  void initState() {
    super.initState();
    _selectedFiles = [...widget.initialSelection];
  }

  Future<List<MapEntry<MediaItem, Uint8List?>>> _getFilesWithBytes(
    List<MediaItem> items,
  ) async {
    final result = <MapEntry<MediaItem, Uint8List?>>[];

    for (final item in items) {
      try {
        final bytes = await widget.mediaLibrary.getFileBytes(item.uri);
        result.add(MapEntry(item, bytes));
      } catch (e) {
        result.add(MapEntry(item, null));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MediaPickerConfigScope(
      config: widget.config,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
        ),
        child: SizedBox(
          width: 520,
          height: 520,
          child: Column(
            children: [
              AppBar(
                title: Text(S.of(context).selectMedia),
                automaticallyImplyLeading: false,
                actions: [
                  TextButton(
                    onPressed: _selectedFiles.isEmpty
                        ? null
                        : () async {
                            final filesWithBytes = await _getFilesWithBytes(
                              _selectedFiles,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop(filesWithBytes);
                            }
                          },
                    child: Text(S.of(context).confirm),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
            ],
          ),
        ),
      ),
    );
  }
}
