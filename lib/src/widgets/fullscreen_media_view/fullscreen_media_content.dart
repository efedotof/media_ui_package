import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'errors_widget.dart';
import 'loading_widget.dart';
import 'image_viewer_widget.dart';
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
                (mediaItems, thumbnailCache, _, __, ___, ____, selectedItems) {
                  if (mediaItems.isEmpty) {
                    return const Center(
                      child: Text(
                        'No media',
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
    } else {
      return BlocBuilder<FullScreenMediaCubit, FullScreenMediaState>(
        builder: (context, state) {
          final screenSize = MediaQuery.of(context).size;
          return state.when(
            initial: () => LoadingWidget(screenSize: screenSize),
            loading: () => LoadingWidget(screenSize: screenSize),
            error: (message) =>
                ErrorsWidget(screenSize: screenSize, message: message),
            loaded: (mediaItems, currentIndex, imageCache, _, __) {
              if (mediaItems.isEmpty) {
                return const Center(
                  child: Text(
                    'No media',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }

              return PageView.builder(
                controller: controller,
                itemCount: mediaItems.length,
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
