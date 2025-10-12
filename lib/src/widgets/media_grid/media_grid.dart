import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'media_grid_controller.dart';
import 'media_grid_item.dart';

class MediaGrid extends StatefulWidget {
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final bool showVideos;
  final ScrollController? scrollController;
  final Uint8List? Function(MediaItem)? thumbnailBuilder;
  final String? albumId;
  final MediaType mediaType;

  const MediaGrid({
    super.key,
    required this.selectedItems,
    required this.onItemSelected,
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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = MediaGridController(
      mediaType: widget.mediaType,
      albumId: widget.albumId,
      thumbnailBuilder: widget.thumbnailBuilder,
      scrollController: widget.scrollController,
      selectedItems: widget.selectedItems,
      onItemSelected: widget.onItemSelected,
      onUpdate: () {
        if (!_isDisposed && mounted) {
          setState(() {});
        }
      },
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller;
    final config = MediaPickerConfig.of(context);

    if (state.isRequestingPermission) {
      return state.buildLoadingWidget(context);
    }

    if (!state.hasPermission && !state.isLoading) {
      return state.buildErrorWidget(context, () {
        if (!_isDisposed && mounted) {
          _controller.checkPermissionAndLoadMedia();
        }
      });
    }

    if (state.isLoading && state.mediaItems.isEmpty) {
      return state.buildLoadingWidget(context);
    }

    if (state.mediaItems.isEmpty) {
      return state.buildEmptyWidget(context);
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
        padding: EdgeInsets.all(config.gridSpacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: config.gridSpacing,
          mainAxisSpacing: config.gridSpacing,
          childAspectRatio: 1,
        ),
        itemCount: state.mediaItems.length + (state.hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.mediaItems.length) {
            final theme = Theme.of(context);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: state.isLoadingMore
                    ? CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      )
                    : Text(
                        'No more items',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(5),
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
            key: ValueKey(item.id),
            item: item,
            isSelected: isSelected,
            selectionIndex: selectionIndex,
            thumbnail: state.getThumbnail(item),
            isLoading: state.isThumbnailLoading(item),
            onThumbnailTap: () =>
                _controller.openFullScreenView(context, index),
            onSelectionTap: () => widget.onItemSelected(item, !isSelected),
            onRetryLoad: () => _controller.loadThumbnail(item),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }
}
