import 'dart:typed_data';
import 'package:flutter/material.dart';

class LoadedMediaContent extends StatelessWidget {
  final Uint8List? mediaLoaded;
  final List<Uint8List>? mediasLoaded;
  final PageController controller;

  const LoadedMediaContent({
    super.key,
    this.mediaLoaded,
    this.mediasLoaded,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Одно загруженное изображение
    if (mediaLoaded != null) {
      return _buildSingleImage(mediaLoaded!);
    }

    // Несколько загруженных изображений
    if (mediasLoaded != null && mediasLoaded!.isNotEmpty) {
      return _buildMultipleImages(mediasLoaded!);
    }

    // Fallback - пустой контейнер
    return Container();
  }

  Widget _buildSingleImage(Uint8List imageBytes) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 1.0,
      maxScale: 3.0,
      child: Image.memory(
        imageBytes,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildMultipleImages(List<Uint8List> images) {
    if (images.length == 1) {
      return _buildSingleImage(images.first);
    }

    return PageView.builder(
      controller: PageController(initialPage: 0, viewportFraction: 0.92),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.memory(
                images[index],
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      },
    );
  }
}
