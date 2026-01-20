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
  PageController? _pageController;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }

  void _initializePageController() {
    // Определяем количество элементов для текущего режима
    final itemCount = _getItemCount();

    // Создаем PageController только если есть хотя бы один элемент
    if (itemCount > 0) {
      final initialIndex = widget.initialIndex ?? 0;
      // Убеждаемся, что initialIndex в пределах допустимого
      final safeInitialIndex = initialIndex.clamp(0, itemCount - 1);
      _pageController = PageController(initialPage: safeInitialIndex);
    }
  }

  int _getItemCount() {
    if (widget.mediaLoaded != null) {
      return 1;
    }
    if (widget.mediasLoaded?.isNotEmpty ?? false) {
      return widget.mediasLoaded!.length;
    }
    if (widget.urlMedial?.isNotEmpty ?? false) {
      return 1;
    }
    if (widget.urlMedias?.isNotEmpty ?? false) {
      return widget.urlMedias!.length;
    }
    if (widget.mediaItems?.isNotEmpty ?? false) {
      return widget.mediaItems!.length;
    }
    return 0;
  }

  List<String> _getUrls() {
    final urls = <String>[];
    if (widget.urlMedial?.isNotEmpty ?? false) {
      urls.add(widget.urlMedial!);
    }
    if (widget.urlMedias?.isNotEmpty ?? false) {
      urls.addAll(widget.urlMedias!);
    }
    return urls;
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            const Center(
              child: Text(
                'Нет доступных медиа',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Определяем текущий режим
    final isLoadedMode =
        widget.mediaLoaded != null ||
        (widget.mediasLoaded?.isNotEmpty ?? false);

    final isUrlMode =
        !isLoadedMode &&
        widget.urlMedia &&
        ((widget.urlMedial?.isNotEmpty ?? false) ||
            (widget.urlMedias?.isNotEmpty ?? false));

    // Проверяем, есть ли данные для отображения
    final itemCount = _getItemCount();
    if (itemCount == 0) {
      return _buildEmptyState();
    }

    // Если PageController еще не создан (например, из-за асинхронной загрузки),
    // создаем его сейчас
    if (_pageController == null) {
      final initialIndex = widget.initialIndex ?? 0;
      final safeInitialIndex = initialIndex.clamp(0, itemCount - 1);
      _pageController = PageController(initialPage: safeInitialIndex);
    }

    // Определяем содержимое в зависимости от режима
    Widget content;
    if (isLoadedMode) {
      content = LoadedMediaContent(
        mediaLoaded: widget.mediaLoaded,
        mediasLoaded: widget.mediasLoaded,
        controller: _pageController!,
      );
    } else if (isUrlMode) {
      final urls = _getUrls();
      content = UrlMediaContent(urls: urls, controller: _pageController!);
    } else {
      content = FullScreenMediaContent(controller: _pageController!);
    }

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
        body: GestureDetector(
          onTap: () => setState(() => _showOverlay = !_showOverlay),
          child: Stack(
            children: [
              content,
              if (_showOverlay)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: RoundButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              if (_showOverlay && widget.showSelectionIndicator)
                const FullScreenMediaOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
}
