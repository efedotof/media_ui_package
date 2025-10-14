import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/widgets/media_grid/selection_indicator_widget.dart';
import 'package:media_ui_package/src/widgets/media_grid/video_info_widget.dart';
import 'thumbnail_widget.dart';

class MediaGridItem extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final int selectionIndex;
  final Uint8List? thumbnail;
  final bool isLoading;
  final VoidCallback onThumbnailTap;
  final VoidCallback onSelectionTap;
  final VoidCallback onRetryLoad;

  const MediaGridItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.selectionIndex,
    required this.thumbnail,
    required this.isLoading,
    required this.onThumbnailTap,
    required this.onSelectionTap,
    required this.onRetryLoad,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = MediaPickerConfig.of(context);

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ThumbnailWidget(
              onThumbnailTap: onThumbnailTap,
              colorScheme: colorScheme,
              isLoading: isLoading,
              item: item,
              onRetryLoad: onRetryLoad,
            ),
            SelectionIndicatorWidget(
              config: config,
              colorScheme: colorScheme,
              onSelectionTap: onSelectionTap,
              isSelected: isSelected,
              selectionIndex: selectionIndex,
            ),
            VideoInfoWidget(item: item, colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}
