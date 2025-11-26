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
    if (mediaLoaded != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 3.0,
            child: Image.memory(
              mediaLoaded!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }

    if (mediasLoaded != null && mediasLoaded!.isNotEmpty) {
      if (mediasLoaded!.length == 1) {
        return Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.memory(
                mediasLoaded!.first,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      }

      return PageView.builder(
        controller: controller,
        itemCount: mediasLoaded!.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 3.0,
                child: Image.memory(
                  mediasLoaded![index],
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(color: Colors.black);
  }
}
