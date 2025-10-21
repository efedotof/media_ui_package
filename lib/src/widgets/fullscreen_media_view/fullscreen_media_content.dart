import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'loading_widget.dart';
import 'errors_widget.dart';

class FullScreenMediaContent extends StatelessWidget {
  final PageController controller;
  const FullScreenMediaContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Пробуем получить MediaGridCubit из контекста
    final mediaGridCubit = context.read<MediaGridCubit?>();

    if (mediaGridCubit != null) {
      // Режим с MediaGridCubit (из галереи)
      return BlocBuilder<MediaGridCubit, MediaGridState>(
        builder: (context, state) {
          final screenSize = MediaQuery.of(context).size;

          return state.when(
            initial: () => LoadingWidget(screenSize: screenSize),
            loading: () => LoadingWidget(screenSize: screenSize),
            permissionRequesting: () => LoadingWidget(screenSize: screenSize),
            permissionDenied: () => ErrorsWidget(
              screenSize: screenSize,
              message: 'Permission denied',
            ),
            error: (message) =>
                ErrorsWidget(screenSize: screenSize, message: message),
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
                  return _buildMediaGridContent(
                    context,
                    mediaItems,
                    thumbnailCache,
                    selectedMediaItems,
                    screenSize,
                  );
                },
          );
        },
      );
    } else {
      // Режим с FullScreenMediaCubit (отдельный полноэкранный просмотр)
      return BlocBuilder<FullScreenMediaCubit, FullScreenMediaState>(
        builder: (context, state) {
          final cubit = context.read<FullScreenMediaCubit>();
          final screenSize = MediaQuery.of(context).size;

          return state.when(
            initial: () => LoadingWidget(screenSize: screenSize),
            loading: () => LoadingWidget(screenSize: screenSize),
            error: (message) =>
                ErrorsWidget(screenSize: screenSize, message: message),
            loaded:
                (
                  mediaItems,
                  currentIndex,
                  imageCache,
                  showSelectionIndicators,
                  selectedMediaItems,
                ) {
                  return _buildFullScreenContent(
                    context,
                    cubit,
                    mediaItems,
                    currentIndex,
                    imageCache,
                    screenSize,
                  );
                },
          );
        },
      );
    }
  }

  Widget _buildMediaGridContent(
    BuildContext context,
    List<MediaItem> mediaItems,
    Map<String, Uint8List?> thumbnailCache,
    List<MediaItem> selectedMediaItems,
    Size screenSize,
  ) {
    if (mediaItems.isEmpty) {
      return Center(
        child: Text(
          'No media files',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return PageView.builder(
      controller: controller,
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final item = mediaItems[index];
        final data = thumbnailCache[item.id];
        final isSelected = selectedMediaItems.contains(item);

        if (data != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Image.memory(
                      data,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${selectedMediaItems.indexOf(item) + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return LoadingWidget(screenSize: screenSize);
      },
    );
  }

  Widget _buildFullScreenContent(
    BuildContext context,
    FullScreenMediaCubit cubit,
    List<MediaItem> mediaItems,
    int currentIndex,
    Map<String, Uint8List?> imageCache,
    Size screenSize,
  ) {
    if (mediaItems.isEmpty) {
      return Center(
        child: Text(
          'No media files',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    if (mediaItems.length == 1) {
      final item = mediaItems.first;
      final data = imageCache[item.id];

      if (data != null) {
        return InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 3.0,
          child: Image.memory(
            data,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );
      }

      return LoadingWidget(screenSize: screenSize);
    }

    return PageView.builder(
      controller: PageController(
        initialPage: currentIndex,
        viewportFraction: 0.92,
      ),
      itemCount: mediaItems.length,
      onPageChanged: cubit.onPageChanged,
      itemBuilder: (context, index) {
        final item = mediaItems[index];
        final data = imageCache[item.id];

        if (data != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 3.0,
                child: Image.memory(
                  data,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          );
        }

        return LoadingWidget(screenSize: screenSize);
      },
    );
  }
}
