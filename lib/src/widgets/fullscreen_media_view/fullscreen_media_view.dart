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
    final itemCount = _getItemCount();

    if (itemCount > 0) {
      final initialIndex = widget.initialIndex ?? 0;
      final safeInitialIndex = initialIndex.clamp(0, itemCount - 1);
      _pageController = PageController(initialPage: safeInitialIndex);
    } else {
      debugPrint('FullscreenMediaView: Нет элементов для отображения');
    }
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) return false;

      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif') ||
          path.endsWith('.webp') ||
          path.endsWith('.bmp') ||
          path.contains('image') ||
          uri.query.contains('image') ||
          true;
    } catch (e) {
      return false;
    }
  }

  int _getItemCount() {
    if (widget.mediaLoaded != null) {
      return 1;
    }

    if (widget.mediasLoaded?.isNotEmpty ?? false) {
      return widget.mediasLoaded!.length;
    }

    if (widget.urlMedia) {
      final hasUrlMedial = _isValidImageUrl(widget.urlMedial);

      final hasUrlMedias =
          widget.urlMedias != null &&
          widget.urlMedias!.isNotEmpty &&
          widget.urlMedias!.any((url) => _isValidImageUrl(url));

      if (hasUrlMedial) {
        return 1;
      }

      if (hasUrlMedias) {
        return widget.urlMedias!.where((url) => _isValidImageUrl(url)).length;
      }

      return 0;
    }

    if (widget.mediaItems?.isNotEmpty ?? false) {
      return widget.mediaItems!.length;
    }

    return 0;
  }

  List<String> _getValidUrls() {
    final urls = <String>[];

    if (_isValidImageUrl(widget.urlMedial)) {
      urls.add(widget.urlMedial!);
    }

    if (widget.urlMedias != null && widget.urlMedias!.isNotEmpty) {
      urls.addAll(widget.urlMedias!.where((url) => _isValidImageUrl(url)));
    }

    return urls;
  }

  Widget _buildContent(BuildContext context) {
    final isLoadedMode =
        widget.mediaLoaded != null ||
        (widget.mediasLoaded?.isNotEmpty ?? false);

    final urls = _getValidUrls();
    final isUrlMode = !isLoadedMode && widget.urlMedia && urls.isNotEmpty;
    final isMediaItemsMode =
        !isLoadedMode && !isUrlMode && (widget.mediaItems?.isNotEmpty ?? false);

    if (isUrlMode) {
      return UrlMediaContent(urls: urls, controller: _pageController!);
    } else if (isLoadedMode) {
      return LoadedMediaContent(
        mediaLoaded: widget.mediaLoaded,
        mediasLoaded: widget.mediasLoaded,
        controller: _pageController!,
      );
    } else if (isMediaItemsMode) {
      return BlocProvider(
        create: (_) => FullScreenMediaCubit(
          mediaItems: widget.mediaItems!,
          initialIndex: widget.initialIndex ?? 0,
          selectedItems: widget.selectedItems ?? [],
          onItemSelected: widget.onItemSelected ?? (_, __) {},
          showSelectionIndicators: widget.showSelectionIndicator,
        ),
        child: FullScreenMediaContent(controller: _pageController!),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _getItemCount();

    if (itemCount == 0) {
      debugPrint(
        'FullscreenMediaView: Пустой контент, показываем состояние "Нет медиа"',
      );
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.white.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Нет доступных медиа',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
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
      );
    }

    if (_pageController == null && itemCount > 0) {
      final initialIndex = widget.initialIndex ?? 0;
      final safeInitialIndex = initialIndex.clamp(0, itemCount - 1);
      _pageController = PageController(initialPage: safeInitialIndex);
    }

    final isMediaItemsMode =
        !widget.urlMedia &&
        !(widget.mediaLoaded != null ||
            (widget.mediasLoaded?.isNotEmpty ?? false)) &&
        (widget.mediaItems?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showOverlay = !_showOverlay),
        child: Stack(
          children: [
            _buildContent(context),

            if (_showOverlay) ...[
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: RoundButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),

              if (_showOverlay &&
                  widget.showSelectionIndicator &&
                  isMediaItemsMode)
                const FullScreenMediaOverlay(),
            ],
          ],
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
