import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/src/widgets/fullscreen_media_view/cubit/full_screen_media_cubit.dart';
import 'loading_widget.dart';

import 'errors_widget.dart';

class FullScreenMediaContent extends StatelessWidget {
  final PageController controller;
  const FullScreenMediaContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
              (mediaItems, currentIndex, imageCache, showSelectionIndicators) {
                return Container(
                  color: Colors.black,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: mediaItems.length,
                    onPageChanged: cubit.onPageChanged,
                    itemBuilder: (context, index) {
                      final item = mediaItems[index];
                      final data = imageCache[item.id];

                      if (data != null) {
                        return SizedBox(
                          width: screenSize.width,
                          height: screenSize.height,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 1.0,
                            maxScale: 3.0,
                            boundaryMargin: EdgeInsets.all(double.infinity),
                            child: Image.memory(
                              data,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              width: screenSize.width,
                              height: screenSize.height,
                            ),
                          ),
                        );
                      }

                      return LoadingWidget(screenSize: screenSize);
                    },
                  ),
                );
              },
        );
      },
    );
  }
}
