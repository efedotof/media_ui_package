import 'dart:typed_data';

import 'package:flutter/material.dart';

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
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: Image.memory(
                imageData,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
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
