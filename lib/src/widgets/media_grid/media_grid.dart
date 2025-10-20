import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'media_grid_item.dart';
import 'media_grid_error_widget.dart';
import 'media_grid_loading_widget.dart';

class MediaGrid extends StatefulWidget {
  const MediaGrid({super.key});

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final position = _scrollController.position;
      final isNearBottom = position.pixels >= position.maxScrollExtent * 0.8;
      if (isNearBottom) {
        context.read<MediaGridCubit>().loadMedia();
      }
    });
  }

  void _openFullScreen(
    BuildContext context,
    int index,
    List<MediaItem> mediaItems,
  ) {
    final cubit = context.read<MediaGridCubit>();
    final state = cubit.state;

    state.whenOrNull(
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FullscreenMediaView(
                  mediaItems: mediaItems,
                  initialIndex: index,
                  selectedItems: selectedMediaItems,
                  onItemSelected: (item, selected) {
                    cubit.toggleSelection(item);
                  },
                ),
              ),
            );
          },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaGridCubit, MediaGridState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return state.when(
          initial: () =>
              const MediaGridLoadingWidget(isRequestingPermission: false),
          loading: () =>
              const MediaGridLoadingWidget(isRequestingPermission: false),
          permissionRequesting: () =>
              const MediaGridLoadingWidget(isRequestingPermission: true),
          permissionDenied: () => MediaGridErrorWidget(
            onRetry: () =>
                context.read<MediaGridCubit>().checkPermissionAndLoadMedia(),
            isRequestingPermission: false,
          ),
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
                if (mediaItems.isEmpty) {
                  return const Center(child: Text('No media files'));
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: mediaItems.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= mediaItems.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final mediaItem = mediaItems[index];
                    final isSelected = selectedMediaItems.contains(mediaItem);
                    final selectionIndex = isSelected
                        ? selectedMediaItems.indexOf(mediaItem) + 1
                        : 0;

                    return MediaGridItem(
                      item: mediaItem,
                      colorScheme: Theme.of(context).colorScheme,
                      isSelected: isSelected,
                      selectionIndex: selectionIndex,
                      onSelect: () {
                        context.read<MediaGridCubit>().toggleSelection(
                          mediaItem,
                        );
                      },
                      onThumbnailTap: () =>
                          _openFullScreen(context, index, mediaItems),
                    );
                  },
                );
              },
          error: (message) => MediaGridErrorWidget(
            onRetry: () =>
                context.read<MediaGridCubit>().checkPermissionAndLoadMedia(),
            isRequestingPermission: false,
          ),
        );
      },
    );
  }
}
