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
        (widget.mediasLoaded != null && widget.mediasLoaded!.isNotEmpty);

    final isUrlMode =
        !isLoadedMode &&
        widget.urlMedia &&
        ((widget.urlMedial != null && widget.urlMedial!.isNotEmpty) ||
            (widget.urlMedias != null && widget.urlMedias!.isNotEmpty));

    if (!isLoadedMode && !isUrlMode) {
      return _buildMediaGalleryContent();
    }

    return BlocProvider(
      create: (_) => FullScreenMediaCubit(
        mediaItems: widget.mediaItems ?? [],
        initialIndex: widget.initialIndex ?? 0,
        selectedItems: widget.selectedItems ?? [],
        onItemSelected: widget.onItemSelected ?? (_, __) {},
        showSelectionIndicators: widget.showSelectionIndicator,
      ),
      child: _buildContent(isLoadedMode, isUrlMode),
    );
  }

  Widget _buildMediaGalleryContent() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            FullScreenMediaContent(controller: _pageController),

            if (_showOverlay) _buildOverlayForGallery(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayForGallery() {
    return BlocBuilder<MediaGridCubit, MediaGridState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded:
              (
                mediaItems,
                thumbnailCache,
                hasMoreItems,
                currentOffset,
                isLoadingMore,
                showSelectionIndicators,
                selectedMediaItems,
              ) {
                final cubit = context.read<MediaGridCubit>();
                final currentIndex = _pageController.hasClients
                    ? _pageController.page?.round() ?? widget.initialIndex ?? 0
                    : widget.initialIndex ?? 0;

                if (currentIndex >= mediaItems.length) return const SizedBox();

                final currentItem = mediaItems[currentIndex];
                final isSelected = selectedMediaItems.contains(currentItem);
                final selectionIndex = isSelected
                    ? selectedMediaItems.indexOf(currentItem) + 1
                    : 0;

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(150),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withAlpha(150),
                          ],
                          stops: const [0.0, 0.1, 0.9, 1.0],
                        ),
                      ),
                    ),

                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      child: RoundButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),

                    if (widget.showSelectionIndicator)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => cubit.toggleSelection(currentItem),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Text(
                                      '$selectionIndex',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1}/${mediaItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (selectedMediaItems.isNotEmpty)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Selected: ${selectedMediaItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
          orElse: () => _buildBackButton(),
        );
      },
    );
  }

  Widget _buildContent(bool isLoadedMode, bool isUrlMode) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            if (isLoadedMode)
              LoadedMediaContent(
                mediaLoaded: widget.mediaLoaded,
                mediasLoaded: widget.mediasLoaded,
                controller: _pageController,
              )
            else if (isUrlMode)
              _buildUrlMediaContent()
            else
              FullScreenMediaContent(controller: _pageController),

            if (_showOverlay) _buildOverlay(isLoadedMode, isUrlMode),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlMediaContent() {
    final urls = <String>[];
    if (widget.urlMedial != null && widget.urlMedial!.isNotEmpty) {
      urls.add(widget.urlMedial!);
    }
    if (widget.urlMedias != null && widget.urlMedias!.isNotEmpty) {
      urls.addAll(widget.urlMedias!);
    }

    return UrlMediaContent(urls: urls, controller: _pageController);
  }

  Widget _buildOverlay(bool isLoadedMode, bool isUrlMode) {
    if (isLoadedMode || isUrlMode) {
      return _buildBackButton();
    }

    return widget.showSelectionIndicator
        ? const FullScreenMediaOverlay()
        : _buildBackButton();
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: RoundButton(
        icon: Icons.arrow_back,
        onTap: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
