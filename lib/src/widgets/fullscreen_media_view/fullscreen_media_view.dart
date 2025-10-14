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
  final bool showSelectionIndicators;

  const FullScreenMediaView({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    required this.selectedItems,
    required this.onItemSelected,
    this.showSelectionIndicators = true,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late final FullScreenMediaController _controller;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _controller = FullScreenMediaController(
      mediaItems: widget.mediaItems,
      initialIndex: widget.initialIndex,
      selectedItems: widget.selectedItems,
      onItemSelected: widget.onItemSelected,
      onUpdate: () => setState(() {}),
      showSelectionIndicators: widget.showSelectionIndicators,
    );
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            FullScreenMediaContent(controller: _controller),

            if (_showOverlay) FullScreenMediaOverlay(controller: _controller),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
