import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'media_thumbnail_cache.dart';

class ThumbnailOrIcon extends StatelessWidget {
  final String mediaId;
  final String mediaType;
  final int size;
  final bool isVideo;

  const ThumbnailOrIcon({
    super.key,
    required this.mediaId,
    required this.mediaType,
    required this.size,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackColor = isVideo ? Colors.red : Colors.green;
    final fallbackIcon = isVideo ? Icons.videocam : Icons.image;

    return FutureBuilder<Uint8List?>(
      future: MediaThumbnailCache.load(mediaId, mediaType, size, size),
      builder: (context, snap) {
        if (snap.hasData && snap.data != null) {
          return Image.memory(
            snap.data!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          );
        }
        return Container(
          color: fallbackColor.withValues(alpha: 0.2),
          child: Icon(fallbackIcon, size: 32, color: fallbackColor),
        );
      },
    );
  }
}
