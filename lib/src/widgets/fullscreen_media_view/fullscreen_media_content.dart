import 'package:flutter/material.dart';
import 'fullscreen_media_controller.dart';

class FullScreenMediaContent extends StatelessWidget {
  final FullScreenMediaController controller;

  const FullScreenMediaContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      color: Colors.black,
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: controller.mediaItems.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final item = controller.mediaItems[index];
          final data = controller.imageCache[item.id];

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
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  width: screenSize.width,
                  height: screenSize.height,
                ),
              ),
            );
          }

          return SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text('Loading...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
