import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'media_grid_controller.dart';
import 'media_grid_item.dart';

class MediaGrid extends StatefulWidget {
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final MediaPickerTheme theme;
  final bool showVideos;
  final ScrollController? scrollController;
  final Future<Uint8List?> Function(MediaItem)? thumbnailBuilder;
  final String? albumId;
  final MediaType mediaType;

  const MediaGrid({
    super.key,
    required this.selectedItems,
    required this.onItemSelected,
    required this.theme,
    this.showVideos = true,
    this.scrollController,
    this.thumbnailBuilder,
    this.albumId,
    this.mediaType = MediaType.all,
  });

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  late final MediaGridController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MediaGridController(
      theme: widget.theme,
      mediaType: widget.mediaType,
      albumId: widget.albumId,
      thumbnailBuilder: widget.thumbnailBuilder,
      scrollController: widget.scrollController,
      selectedItems: widget.selectedItems,
      onItemSelected: widget.onItemSelected,
      onUpdate: () => setState(() {}),
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller;

    // Показываем индикатор запроса разрешения
    if (state.isRequestingPermission) {
      return state.buildLoadingWidget();
    }

    // Показываем ошибку, если нет разрешения и не загружается
    if (!state.hasPermission && !state.isLoading) {
      return state.buildErrorWidget(() {
        _controller.checkPermissionAndLoadMedia();
      });
    }

    // Показываем загрузку при первой загрузке
    if (state.isLoading && state.mediaItems.isEmpty) {
      return state.buildLoadingWidget();
    }

    // Показываем пустой виджет, если медиа нет
    if (state.mediaItems.isEmpty) {
      return state.buildEmptyWidget();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll is ScrollEndNotification) {
          final metrics = scroll.metrics;
          if (metrics.atEdge && metrics.pixels != 0) {
            _controller.loadMoreMedia();
          }
        }
        return false;
      },
      child: GridView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.all(widget.theme.gridSpacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: widget.theme.gridSpacing,
          mainAxisSpacing: widget.theme.gridSpacing,
          childAspectRatio: 1,
        ),
        itemCount: state.mediaItems.length + (state.hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.mediaItems.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: state.isLoadingMore
                    ? CircularProgressIndicator(
                        color: widget.theme.primaryColor,
                      )
                    : Text(
                        'No more items',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                        ),
                      ),
              ),
            );
          }

          final item = state.mediaItems[index];
          final isSelected = widget.selectedItems.any(
            (selected) => selected.id == item.id,
          );
          final selectionIndex = isSelected
              ? widget.selectedItems.indexWhere((s) => s.id == item.id) + 1
              : 0;

          return MediaGridItem(
            item: item,
            isSelected: isSelected,
            selectionIndex: selectionIndex,
            theme: widget.theme,
            thumbnailFuture: state.getThumbnailFuture(item),
            onThumbnailTap: () =>
                _controller.openFullScreenView(context, index),
            onSelectionTap: () => widget.onItemSelected(item, !isSelected),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
