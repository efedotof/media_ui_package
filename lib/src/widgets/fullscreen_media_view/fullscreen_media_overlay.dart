import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/cubit/full_screen_media_cubit.dart';
import 'round_button.dart';

class FullScreenMediaOverlay extends StatelessWidget {
  final Uint8List? mediaLoaded;
  final List<Uint8List>? mediasLoaded;

  const FullScreenMediaOverlay({
    super.key,
    this.mediaLoaded,
    this.mediasLoaded,
  });

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('Building FullScreenMediaOverlay');
    }

    return BlocBuilder<FullScreenMediaCubit, FullScreenMediaState>(
      builder: (context, state) {
        if (kDebugMode) {
          debugPrint('FullScreenMediaOverlay state: $state');
        }

        return state.maybeWhen(
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
                final cubit = context.read<FullScreenMediaCubit>();
                final currentItem = mediaItems[currentIndex];
                final selected = cubit.isSelected(currentItem);
                final selectionIndex = cubit.getSelectionIndex(currentItem);

                final isVideo =
                    currentItem.type == 'video' ||
                    currentItem.type == 'videos' ||
                    currentItem.type == MediaType.videos.name;

                if (kDebugMode) {
                  debugPrint(
                    'Is video: $isVideo, videoDuration: $videoDuration, videoPosition: $videoPosition',
                  );
                }

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: Colors.transparent),
                    ),

                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      child: RoundButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),

                    if (showSelectionIndicators)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => cubit.toggleSelection(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: selected
                                ? Center(
                                    child: Text(
                                      '$selectionIndex',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                          ),
                        ),
                      ),

                    if (isVideo &&
                        videoDuration != null &&
                        videoPosition != null)
                      Positioned.fill(
                        child: _buildVideoControls(
                          context,
                          cubit,
                          isVideoPlaying ?? false,
                          videoPosition,
                          videoDuration,
                          currentItem.name,
                        ),
                      ),

                    Positioned(
                      bottom:
                          (isVideo &&
                              videoDuration != null &&
                              videoPosition != null)
                          ? MediaQuery.of(context).padding.bottom + 120
                          : MediaQuery.of(context).padding.bottom + 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${mediasLoaded?.length ?? mediaItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (selectedMediaItems.isNotEmpty)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${selectedMediaItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
          orElse: () {
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildVideoControls(
    BuildContext context,
    FullScreenMediaCubit cubit,
    bool isPlaying,
    double position,
    double duration,
    String videoName,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.replay_10,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () => cubit.seekBackward(),
                ),

                const SizedBox(width: 32),

                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 64,
                  ),
                  onPressed: () => cubit.toggleVideoPlayPause(),
                ),

                const SizedBox(width: 32),

                IconButton(
                  icon: const Icon(
                    Icons.forward_10,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () => cubit.seekForward(),
                ),
              ],
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: position,
                          min: 0,
                          max: duration > 0 ? duration : 1,
                          onChanged: (value) {},
                          onChangeEnd: (value) => cubit.seekVideo(value),
                          activeColor: Colors.red,
                          inactiveColor: Color.fromRGBO(255, 255, 255, 0.3),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                videoName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
