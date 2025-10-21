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
                        return Container(
                          color: Colors.black,
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.5,
                                maxScale: 5.0,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Image.memory(
                                      data,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
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
                                      '$selectionIndex',
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
                        );
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
                      return Container(
                        color: Colors.black,
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 5.0,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Image.memory(
                                data,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      );
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
                        return Container(
                          color: Colors.black,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 5.0,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Image.memory(
                                  data,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        );
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
