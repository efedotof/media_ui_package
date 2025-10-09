import 'package:flutter/material.dart';
import 'fullscreen_media_controller.dart';
import 'round_button.dart';

class FullScreenMediaOverlay extends StatelessWidget {
  final FullScreenMediaController controller;

  const FullScreenMediaOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentItem = controller.mediaItems[controller.currentIndex];
    final selected = controller.isSelected(currentItem);

    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: RoundButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: GestureDetector(
            onTap: controller.toggleSelection,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: selected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: controller.theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${controller.getSelectionIndex(currentItem)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),

        if (controller.mediaItems.length > 1)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.currentIndex + 1}/${controller.mediaItems.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
