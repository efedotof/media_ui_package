import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/cubit/full_screen_media_cubit.dart';
import 'fullscreen_media_content.dart';
import 'fullscreen_media_overlay.dart';
import 'url_media_content.dart';

class FullscreenMediaView extends StatefulWidget {
  final List<MediaItem>? mediaItems;
  final int? initialIndex;
  final List<MediaItem>? selectedItems;
  final Function(MediaItem, bool)? onItemSelected;

  final bool urlMedia; // показывать медиа из интернета
  final String? urlMedial; // один URL
  final List<String>? urlMedias; // несколько URL

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
    final isUrlMode =
        widget.urlMedia &&
        ((widget.urlMedial != null && widget.urlMedial!.isNotEmpty) ||
            (widget.urlMedias != null && widget.urlMedias!.isNotEmpty));

    final urls = <String>[];
    if (widget.urlMedial != null && widget.urlMedial!.isNotEmpty) {
      urls.add(widget.urlMedial!);
    }
    if (widget.urlMedias != null && widget.urlMedias!.isNotEmpty) {
      urls.addAll(widget.urlMedias!);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            if (isUrlMode)
              UrlMediaContent(urls: urls, controller: _pageController)
            else
              BlocProvider(
                create: (_) => FullScreenMediaCubit(
                  mediaItems: widget.mediaItems ?? [],
                  initialIndex: widget.initialIndex ?? 0,
                  selectedItems: widget.selectedItems ?? [],
                  onItemSelected: widget.onItemSelected ?? (_, __) {},
                  showSelectionIndicators: widget.showSelectionIndicator,
                ),
                child: FullScreenMediaContent(controller: _pageController),
              ),
            if (_showOverlay && widget.showSelectionIndicator)
              if (!isUrlMode) const FullScreenMediaOverlay(),
          ],
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
