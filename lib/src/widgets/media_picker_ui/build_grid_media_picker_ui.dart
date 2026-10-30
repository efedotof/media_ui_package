import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';

import 'media_tile.dart';

class BuildGridMediaPickerUi extends StatelessWidget {
  const BuildGridMediaPickerUi({
    super.key,
    required this.items,
    required this.controller,
    required this.scrollController,
    required this.showLoadMore,
    required this.autoLoadThreshold,
    this.onItemTap,
    required this.thumbnailSize,
  });

  final List<MediaItem> items;
  final MediaPickerController controller;
  final ScrollController? scrollController;
  final bool showLoadMore;
  final double autoLoadThreshold;
  final ValueChanged<MediaItem>? onItemTap;
  final int thumbnailSize;

  @override
  Widget build(BuildContext context) {
    final config = MediaPickerConfig.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: GridView.builder(
        key: const PageStorageKey('media_grid'),
        controller: scrollController,
        padding: EdgeInsets.only(
          left: config.gridSpacing,
          right: config.gridSpacing,
          top: config.gridSpacing,
          bottom: 100,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          crossAxisSpacing: config.gridSpacing,
          mainAxisSpacing: config.gridSpacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return MediaTile(
            item: item,
            isSelected: controller.isSelected(item.id),
            multiSelect: controller.multiSelect,
            thumbnailSize: thumbnailSize,
            onTap: () {
              onItemTap?.call(item);
              controller.toggleSelection(item);
            },
          );
        },
      ),
    );
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - autoLoadThreshold) {
      if (!controller.isLoading && controller.hasMore) {
        controller.loadMore();
      }
    }
    return false;
  }
}
