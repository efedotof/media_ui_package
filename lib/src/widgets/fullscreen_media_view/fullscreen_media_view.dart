import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/cubit/full_screen_media_cubit.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/fullscreen_media_content.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/fullscreen_media_overlay.dart';

class FullscreenMediaView extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final bool showSelectionIndicators;

  const FullscreenMediaView({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    required this.selectedItems,
    required this.onItemSelected,
    this.showSelectionIndicators = true,
  });

  @override
  State<FullscreenMediaView> createState() => _FullscreenMediaViewState();
}

class _FullscreenMediaViewState extends State<FullscreenMediaView> {
  late final PageController _pageController;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FullScreenMediaCubit(
        mediaItems: widget.mediaItems,
        initialIndex: widget.initialIndex,
        selectedItems: widget.selectedItems,
        onItemSelected: widget.onItemSelected,
        showSelectionIndicators: widget.showSelectionIndicators,
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: _toggleOverlay,
          child: Stack(
            children: [
              FullScreenMediaContent(controller: _pageController),

              if (_showOverlay) const FullScreenMediaOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
