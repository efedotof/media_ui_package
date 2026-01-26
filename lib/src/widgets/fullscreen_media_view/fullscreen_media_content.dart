import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'errors_widget.dart';
import 'loading_widget.dart';
import 'image_viewer_widget.dart';
import 'custom_video_player_widget.dart';

class FullScreenMediaContent extends StatelessWidget {
  final PageController controller;
  final bool autoPlayVideos;

  const FullScreenMediaContent({
    super.key,
    required this.controller,
    this.autoPlayVideos = false,
  });

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
              message: S.of(context).permissionDenied,
            ),
            error: (message) =>
                ErrorsWidget(screenSize: screenSize, message: message),
            loaded:
                (mediaItems, thumbnailCache, _, __, ___, ____, selectedItems) {
                  if (mediaItems.isEmpty) {
                    return Center(
                      child: Text(
                        S.of(context).noMedia,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }

                  return PageView.builder(
                    controller: controller,
                    itemCount: mediaItems.length,
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      final data = thumbnailCache[item.id];
                      if (data != null) {
                        if (item.type == 'video' ||
                            item.type == MediaType.videos.name) {
                          return CustomVideoPlayerWidget(
                            mediaItem: item,
                            thumbnailData: data,

                            isSelected: selectedItems.contains(item),
                            selectionIndex: selectedItems.contains(item)
                                ? selectedItems.indexOf(item) + 1
                                : 0,
                          );
                        } else {
                          return ImageViewerWidget(
                            imageData: data,
                            isSelected: selectedItems.contains(item),
                            selectionIndex: selectedItems.contains(item)
                                ? selectedItems.indexOf(item) + 1
                                : 0,
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
                  isVideoPlaying,
                  videoPosition,
                  videoDuration,
                  isVideoBuffering,
                ) {
                  if (mediaItems.isEmpty) {
                    return Center(
                      child: Text(
                        S.of(context).noMedia,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }

                  return PageView.builder(
                    controller: controller,
                    itemCount: mediaItems.length,
                    onPageChanged: (index) {
                      context.read<FullScreenMediaCubit>().onPageChanged(index);
                    },
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      final data = imageCache[item.id];
                      if (data != null) {
                        if (item.type == 'video' ||
                            item.type == MediaType.videos.name) {
                          return CustomVideoPlayerWidget(
                            mediaItem: item,
                            thumbnailData: data,

                            isSelected: selectedMediaItems.any(
                              (e) => e.id == item.id,
                            ),
                            selectionIndex:
                                selectedMediaItems.any((e) => e.id == item.id)
                                ? selectedMediaItems.indexWhere(
                                        (e) => e.id == item.id,
                                      ) +
                                      1
                                : 0,
                          );
                        } else {
                          return ImageViewerWidget(
                            imageData: data,
                            isSelected: selectedMediaItems.any(
                              (e) => e.id == item.id,
                            ),
                            selectionIndex:
                                selectedMediaItems.any((e) => e.id == item.id)
                                ? selectedMediaItems.indexWhere(
                                        (e) => e.id == item.id,
                                      ) +
                                      1
                                : 0,
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
    }
  }
}
