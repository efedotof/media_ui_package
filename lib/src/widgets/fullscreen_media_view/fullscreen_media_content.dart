import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'package:video_player/video_player.dart';

import 'errors_widget.dart';
import 'loading_widget.dart';

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
                        // Check if media is video
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

// Новый виджет для воспроизведения видео
class VideoPlayerWidget extends StatefulWidget {
  final MediaItem mediaItem;
  final Uint8List thumbnailData;
  final bool isSelected;
  final int selectionIndex;

  const VideoPlayerWidget({
    super.key,
    required this.mediaItem,
    required this.thumbnailData,
    this.isSelected = false,
    this.selectionIndex = 0,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.file(File(widget.mediaItem.uri))
        ..addListener(() {
          if (mounted) {
            setState(() {});
          }
        })
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _controller.setLooping(true);
            });
          }
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
        _showControls = true;

        // Скрыть контролы через 3 секунды
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _controller.value.isPlaying) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Видео плеер или превью
            if (_isLoading)
              Center(
                child: Image.memory(widget.thumbnailData, fit: BoxFit.contain),
              )
            else
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),

            // Индикатор загрузки
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Элементы управления видео
            if (_showControls && !_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      const SizedBox(height: 20),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Индикатор воспроизведения в углу
            if (!_showControls && _isPlaying && !_isLoading)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

            // Индикатор выбора
            if (widget.isSelected)
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
                    '${widget.selectionIndex}',
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
}

// Вынесенный виджет для изображений
class ImageViewerWidget extends StatelessWidget {
  final Uint8List imageData;
  final bool isSelected;
  final int selectionIndex;

  const ImageViewerWidget({
    super.key,
    required this.imageData,
    this.isSelected = false,
    this.selectionIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(
            alignment: Alignment.center,
            panEnabled: true,
            minScale: 0.5,
            maxScale: 5.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Image.memory(
                  imageData,
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
}
