import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'fullscreen_media_content.dart';
import 'fullscreen_media_overlay.dart';
import 'round_button.dart';
import 'url_media_content.dart';
import 'loaded_media_content.dart';

class FullscreenMediaView extends StatefulWidget {
  final List<MediaItem>? mediaItems;
  final int? initialIndex;
  final List<MediaItem>? selectedItems;
  final Function(MediaItem, bool)? onItemSelected;
  final bool urlMedia;
  final String? urlMedial;
  final List<String>? urlMedias;
  final Uint8List? mediaLoaded;
  final List<Uint8List>? mediasLoaded;
  final bool showSelectionIndicator;
  final bool autoPlayVideos;

  const FullscreenMediaView({
    super.key,
    this.mediaItems,
    this.initialIndex,
    this.selectedItems,
    this.onItemSelected,
    this.urlMedia = false,
    this.urlMedial,
    this.urlMedias,
    this.mediaLoaded,
    this.mediasLoaded,
    this.showSelectionIndicator = true,
    this.autoPlayVideos = false,
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
    _pageController = PageController(initialPage: widget.initialIndex ?? 0);
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoadedMode =
        widget.mediaLoaded != null ||
        (widget.mediasLoaded?.isNotEmpty ?? false);

    final isUrlMode =
        !isLoadedMode &&
        widget.urlMedia &&
        ((widget.urlMedial?.isNotEmpty ?? false) ||
            (widget.urlMedias?.isNotEmpty ?? false));

    // Если нет медиа из галереи
    if (!isLoadedMode && !isUrlMode) {
      return BlocProvider(
        create: (_) => FullScreenMediaCubit(
          mediaItems: widget.mediaItems ?? [],
          initialIndex: widget.initialIndex ?? 0,
          selectedItems: widget.selectedItems ?? [],
          onItemSelected: widget.onItemSelected ?? (_, __) {},
          showSelectionIndicators: widget.showSelectionIndicator,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Контент
              FullScreenMediaContent(
                controller: _pageController,
                autoPlayVideos: widget.autoPlayVideos,
              ),

              // Оверлей
              if (_showOverlay)
                FullScreenMediaOverlay(
                  mediaLoaded: widget.mediaLoaded,
                  mediasLoaded: widget.mediasLoaded,
                ),
            ],
          ),
        ),
      );
    }

    // Для загруженных медиа или URL
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (isLoadedMode)
            LoadedMediaContent(
              mediaLoaded: widget.mediaLoaded,
              mediasLoaded: widget.mediasLoaded,
              controller: _pageController,
            )
          else if (isUrlMode)
            UrlMediaContent(
              urls: [
                if (widget.urlMedial?.isNotEmpty ?? false) widget.urlMedial!,
                if (widget.urlMedias?.isNotEmpty ?? false) ...widget.urlMedias!,
              ],
              controller: _pageController,
            ),

          if (_showOverlay)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: RoundButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
