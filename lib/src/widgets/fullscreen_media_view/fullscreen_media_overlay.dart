import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/cubit/full_screen_media_cubit.dart';
import 'round_button.dart';

class FullScreenMediaOverlay extends StatelessWidget {
  const FullScreenMediaOverlay({
    super.key,
    this.mediaLoaded,
    this.mediasLoaded,
  });
  final Uint8List? mediaLoaded;
  final List<Uint8List>? mediasLoaded;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FullScreenMediaCubit, FullScreenMediaState>(
      builder: (context, state) {
        final cubit = context.read<FullScreenMediaCubit>();

        return state.maybeWhen(
          loaded:
              (
                mediaItems,
                currentIndex,
                imageCache,
                showSelectionIndicators,
                selectedMediaItems,
              ) {
                final currentItem = mediaItems[currentIndex];
                final selected = cubit.isSelected(currentItem);
                final selectionIndex = cubit.getSelectionIndex(currentItem);

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(150),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withAlpha(150),
                          ],
                          stops: const [0.0, 0.1, 0.9, 1.0],
                        ),
                      ),
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
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: selected
                                ? Center(
                                    child: Text(
                                      '$selectionIndex',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1}/${mediaItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (mediasLoaded != null && mediasLoaded!.length > 1)
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentIndex + 1}/${mediasLoaded!.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (selectedMediaItems.isNotEmpty)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
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
                              'Selected: ${selectedMediaItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
          orElse: () => const SizedBox(),
        );
      },
    );
  }
}
