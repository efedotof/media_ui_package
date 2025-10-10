import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'fullscreen_media_controller.dart';
import 'fullscreen_media_content.dart';
import 'fullscreen_media_overlay.dart';

class FullScreenMediaView extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;

  const FullScreenMediaView({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    required this.selectedItems,
    required this.onItemSelected,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late final FullScreenMediaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FullScreenMediaController(
      mediaItems: widget.mediaItems,
      initialIndex: widget.initialIndex,
      selectedItems: widget.selectedItems,
      onItemSelected: widget.onItemSelected,
      onUpdate: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          FullScreenMediaContent(controller: _controller),
          FullScreenMediaOverlay(controller: _controller),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
