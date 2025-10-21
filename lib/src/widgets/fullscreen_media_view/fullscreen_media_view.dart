import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/cubit/full_screen_media_cubit.dart';
import 'fullscreen_media_content.dart';
import 'fullscreen_media_overlay.dart';
import 'round_button.dart';
import 'url_media_content.dart';
import 'loaded_media_content.dart'; // Новый импорт

class FullscreenMediaView extends StatefulWidget {
  final List<MediaItem>? mediaItems;
  final int? initialIndex;
  final List<MediaItem>? selectedItems;
  final Function(MediaItem, bool)? onItemSelected;

  final bool urlMedia; // показывать медиа из интернета
  final String? urlMedial; // один URL
  final List<String>? urlMedias; // несколько URL
  final Uint8List? mediaLoaded; // если изображение уже было загружено
  final List<Uint8List>? mediasLoaded; // несколько загруженных изображений
  final bool showSelectionIndicator; // показывать индикатор выбора или нет

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

    // Для режима с медиа из галереи используем существующий MediaGridCubit
    if (!isLoadedMode && !isUrlMode) {
      return _buildMediaGalleryContent();
    }

    // Для остальных режимов создаем отдельный cubit
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
            // Используем MediaGridCubit из контекста
            FullScreenMediaContent(controller: _pageController),
            if (_showOverlay && widget.showSelectionIndicator)
              const FullScreenMediaOverlay()
            else if (_showOverlay)
              _buildBackButton(),
          ],
        ),
      ),
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
