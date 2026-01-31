import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';

class DesktopDropZone extends StatefulWidget {
  final Widget child;
  final Future<void> Function(List<MediaItem> files)? onFilesDropped;
  final List<String> allowedExtensions;
  final bool showOverlay;
  final String? overlayText;
  final bool enabled;

  const DesktopDropZone({
    super.key,
    required this.child,
    this.onFilesDropped,
    required this.allowedExtensions,
    this.showOverlay = true,
    this.overlayText,
    this.enabled = true,
  });

  @override
  State<DesktopDropZone> createState() => _DesktopDropZoneState();
}

class _DesktopDropZoneState extends State<DesktopDropZone> {
  bool _dragging = false;

  bool _isFileAllowed(String path) {
    if (widget.allowedExtensions.isEmpty) return true;
    return widget.allowedExtensions.any(
      (e) => path.toLowerCase().endsWith(e.toLowerCase()),
    );
  }

  Future<void> _process(List<String> paths) async {
    final items = <MediaItem>[];

    for (final path in paths) {
      if (!_isFileAllowed(path)) continue;

      try {
        final file = File(path);
        final stat = await file.stat();
        final bytes = await file.readAsBytes();

        String uri;

        uri = Uri.file(path).toString();

        final type = _getType(path);

        items.add(
          MediaItem(
            id: path,
            name: path.split(Platform.pathSeparator).last,
            uri: uri,
            dateAdded: stat.modified.millisecondsSinceEpoch,
            size: stat.size,
            width: 0,
            height: 0,
            albumId: '',
            albumName: '',
            type: type,
            duration: 0,
            thumbnail: bytes,
          ),
        );
        debugPrint("done:${items[0].uri}");
      } catch (e) {
        debugPrint('Error processing file: $e');
      }
    }

    if (items.isNotEmpty && widget.onFilesDropped != null) {
      await widget.onFilesDropped!(items);
    }
  }

  String _getType(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.mp4') ||
        p.endsWith('.mov') ||
        p.endsWith('.avi') ||
        p.endsWith('.mkv') ||
        p.endsWith('.webm')) {
      return 'video';
    }
    return 'image';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (detail) async {
        final paths = detail.files.map((e) => e.path).toList();
        await _process(paths);
        setState(() => _dragging = false);
      },
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (_dragging && widget.showOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                alignment: Alignment.center,
                child: Text(
                  widget.overlayText ?? S.of(context).dropFilesHere,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
