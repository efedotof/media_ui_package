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
              top: 20,
              right: 20,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$selectionIndex',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
