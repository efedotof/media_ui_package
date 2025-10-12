import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

import 'media_grid_helpers.dart';

class VideoInfoWidget extends StatelessWidget {
  const VideoInfoWidget({
    super.key,
    required this.item,
    required this.colorScheme,
  });
  final MediaItem item;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (item.type != 'video') return const SizedBox();
    return Positioned(
      bottom: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 12),
            const SizedBox(width: 2),
            Text(
              formatDuration(item.duration ?? 0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
