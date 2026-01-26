import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'media_grid_item.dart';
import 'media_grid_error_widget.dart';
import 'media_grid_loading_widget.dart';
import 'elastic_item.dart';

class MediaGrid extends StatefulWidget {
  final bool autoPlayVideosInFullscreen;

  const MediaGrid({super.key, this.autoPlayVideosInFullscreen = false});

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
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 100), () {
      final position = _scrollController.position;
      final maxScrollExtent = position.maxScrollExtent;
      final isNearBottom = position.pixels >= maxScrollExtent * 0.8;

      if (isNearBottom) {
        context.read<MediaGridCubit>().loadMedia();
      }
    });
  }

  void _openFullScreen(int index, List<MediaItem> mediaItems) {
    final cubit = context.read<MediaGridCubit>();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BlocProvider.value(
              value: cubit,
              child: FullscreenMediaView(
                mediaItems: mediaItems,
                initialIndex: index,
                selectedItems: cubit.selectedItems,
                onItemSelected: (item, selected) {
                  cubit.toggleSelection(item);
                },
              ),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context).noMediaFiles,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: mediaItems.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= mediaItems.length) {
                      return const ElasticItem(index: 0, totalLoadingItems: 1);
                    }

                    final mediaItem = mediaItems[index];
                    final isSelected = selectedMediaItems.contains(mediaItem);
                    final selectionIndex = isSelected
                        ? selectedMediaItems.indexOf(mediaItem) + 1
                        : 0;

                    return MediaGridItem(
                      key: ValueKey(mediaItem.id),
                      item: mediaItem,
                      colorScheme: Theme.of(context).colorScheme,
                      isSelected: isSelected,
                      selectionIndex: selectionIndex,
                      onSelect: () => context
                          .read<MediaGridCubit>()
                          .toggleSelection(mediaItem),
                      onThumbnailTap: () => _openFullScreen(index, mediaItems),
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
