import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'media_grid_helpers.dart';

class MediaGridItem extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final int selectionIndex;
  final MediaPickerTheme theme;
  final Future<Uint8List?> thumbnailFuture;
  final VoidCallback onThumbnailTap;
  final VoidCallback onSelectionTap;

  const MediaGridItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.selectionIndex,
    required this.theme,
    required this.thumbnailFuture,
    required this.onThumbnailTap,
    required this.onSelectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onThumbnailTap,
          child: FutureBuilder<Uint8List?>(
            future: thumbnailFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(theme.borderRadius),
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
                );
              }

              return Center(
                child: Icon(item.type == 'video' ? Icons.videocam : Icons.photo,
                    color: Colors.grey[600], size: 32),
              );
            },
          ),
        ),
        if (isSelected)
          Container(
            decoration: BoxDecoration(
              color: theme.selectedColor.withAlpha(30),
              borderRadius: BorderRadius.circular(theme.borderRadius),
              border: Border.all(color: theme.selectedColor, width: 3),
            ),
          ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onSelectionTap,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? theme.selectedColor : Colors.white.withAlpha(200),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.selectedColor : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Text('$selectionIndex',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  : null,
            ),
          ),
        ),
        if (item.type == 'video')
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    formatDuration(item.duration ?? 0),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
