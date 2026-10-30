import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/models/media_picker_controller.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';

import 'file_leading.dart';
import 'load_more_tile.dart';
import 'select_indicator.dart';

class BuildFileList extends StatelessWidget {
  const BuildFileList({
    super.key,
    required this.items,
    required this.controller,
    required this.scrollController,
    required this.showLoadMore,
    required this.autoLoadThreshold,
    this.onItemTap,
    required this.inlineImageMaxBytes,
  });

  final List<MediaItem> items;
  final MediaPickerController controller;
  final ScrollController? scrollController;
  final bool showLoadMore;
  final double autoLoadThreshold;
  final ValueChanged<MediaItem>? onItemTap;
  final int inlineImageMaxBytes;

  @override
  Widget build(BuildContext context) {
    final config = MediaPickerConfig.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ListView.separated(
        key: const PageStorageKey('file_list'),
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length + (showLoadMore && controller.hasMore ? 1 : 0),
        separatorBuilder: (_, _) =>
            Divider(height: config.gridSpacing, thickness: 0),
        itemBuilder: (context, i) {
          if (i == items.length) {
            return LoadMoreTile(
              onTap: controller.loadMore,
              isLoading: controller.isLoading,
            );
          }
          final item = items[i];
          final selected = controller.isSelected(item.id);
          final color = _colorForFileType(item.type);
          final icon = _iconForFileType(item.type);

          return ListTile(
            selected: selected,
            leading: FileLeading(
              item: item,
              fallbackColor: color,
              fallbackIcon: icon,
              maxBytes: inlineImageMaxBytes,
            ),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${item.type} · ${_formatBytes(item.size)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: controller.multiSelect
                ? SelectIndicator(selected: selected)
                : (selected ? const Icon(Icons.check_circle) : null),
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

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  static Color _colorForFileType(String type) {
    switch (type) {
      case 'image':
        return Colors.green;
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  static IconData _iconForFileType(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.music_note;
      default:
        return Icons.insert_drive_file;
    }
  }
}
