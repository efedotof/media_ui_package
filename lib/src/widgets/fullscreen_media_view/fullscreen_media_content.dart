import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

import 'errors_widget.dart';
import 'image_viewer_widget.dart';
import 'loading_widget.dart';
import 'video_player_widget.dart';

class FullScreenMediaContent extends StatelessWidget {
  final PageController controller;
  const FullScreenMediaContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final mediaGridCubit = context.read<MediaGridCubit?>();

    if (mediaGridCubit != null) {
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
                      final selectionIndex =
                          selectedMediaItems.indexOf(item) + 1;

                      if (data != null) {
                        if (item.type == MediaType.videos) {
                          return VideoPlayerWidget(
                            mediaItem: item,
                            thumbnailData: data,
                            isSelected: isSelected,
                            selectionIndex: selectionIndex,
                          );
                        } else {
                          return ImageViewerWidget(
                            imageData: data,
                            isSelected: isSelected,
                            selectionIndex: selectionIndex,
                          );
                        }
                      }

                      return LoadingWidget(screenSize: screenSize);
                    },
                  );
                },
          );
        },
      );
    } else {
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
                      if (item.type == MediaType.videos) {
                        return VideoPlayerWidget(
                          mediaItem: item,
                          thumbnailData: data,
                        );
                      } else {
                        return ImageViewerWidget(imageData: data);
                      }
                    }

                    return LoadingWidget(screenSize: screenSize);
                  }

                  return PageView.builder(
                    controller: PageController(
                      initialPage: currentIndex,
                      viewportFraction: 1.0,
                    ),
                    itemCount: mediaItems.length,
                    onPageChanged: cubit.onPageChanged,
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      final data = imageCache[item.id];

                      if (data != null) {
                        if (item.type == MediaType.videos) {
                          return VideoPlayerWidget(
                            mediaItem: item,
                            thumbnailData: data,
                          );
                        } else {
                          return ImageViewerWidget(imageData: data);
                        }
                      }

                      return LoadingWidget(screenSize: screenSize);
                    },
                  );
                },
          );
        },
      );
    }
  }
}
