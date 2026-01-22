import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:media_ui_package/media_ui_package.dart';

class WebDropZone extends StatefulWidget {
  final Widget child;
  final Future<void> Function(List<MediaItem> files)? onFilesDropped;
  final List<String> allowedExtensions;
  final bool showOverlay;
  final String? overlayText;
  final bool enabled;

  const WebDropZone({
    super.key,
    required this.child,
    this.onFilesDropped,
    required this.allowedExtensions,
    this.showOverlay = true,
    this.overlayText,
    this.enabled = true,
  });

  @override
  State<WebDropZone> createState() => _WebDropZoneState();
}

class _WebDropZoneState extends State<WebDropZone> {
  bool _dragging = false;

  bool _isFileAllowed(String name) {
    if (widget.allowedExtensions.isEmpty) return true;
    return widget.allowedExtensions.any(
      (e) => name.toLowerCase().endsWith(e.toLowerCase()),
    );
  }

  Future<void> _process(List<DropItem> items) async {
    final mediaItems = <MediaItem>[];

    for (final item in items) {
      if (!_isFileAllowed(item.name)) continue;

      try {
        final bytes = await item.readAsBytes();
        final mimeType = item.mimeType ?? 'application/octet-stream';

        String uri;
        if (PlatformMediaPickerUtils.isWeb) {
          final base64String = base64Encode(bytes);
          uri = 'data:$mimeType;base64,$base64String';
        } else {
          uri = item.path;
        }

        final fileType = (mimeType.contains('video')) ? 'video' : 'image';

        mediaItems.add(
          MediaItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: item.name,
            uri: uri,
            dateAdded: DateTime.now().millisecondsSinceEpoch,
            size: bytes.length,
            width: 0,
            height: 0,
            albumId: '',
            albumName: '',
            type: fileType,
            duration: 0,
            thumbnail: bytes,
          ),
        );
        debugPrint("done:${mediaItems[0].uri}");
      } catch (e) {
        debugPrint('Error processing file: $e');
      }
    }

    if (mediaItems.isNotEmpty && widget.onFilesDropped != null) {
      await widget.onFilesDropped!(mediaItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (detail) async {
        await _process(detail.files);
        setState(() => _dragging = false);
      },
      child: Stack(
        children: [
          widget.child,
          if (_dragging && widget.showOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Text(
                  widget.overlayText ?? 'Drop files here',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
