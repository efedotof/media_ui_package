import 'package:flutter/material.dart';
import 'fullscreen_media_controller.dart';

class FullScreenMediaContent extends StatelessWidget {
  final FullScreenMediaController controller;

  const FullScreenMediaContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      itemCount: controller.mediaItems.length,
      onPageChanged: controller.onPageChanged,
      itemBuilder: (context, index) {
        final item = controller.mediaItems[index];
        final data = controller.imageCache[item.id];

        if (data != null) {
          return InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 3.0,
            child: Center(
              child: Image.memory(
                data,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: controller.theme.primaryColor),
              const SizedBox(height: 16),
              const Text('Loading...', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }
}
