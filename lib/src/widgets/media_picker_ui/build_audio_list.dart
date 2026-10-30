import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/models/media_picker_controller.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';

import 'load_more_tile.dart';
import 'select_indicator.dart';

class BuildAudioList extends StatelessWidget {
  const BuildAudioList({
    super.key,
    required this.items,
    required this.controller,
    required this.scrollController,
    required this.showLoadMore,
    required this.autoLoadThreshold,
    this.onItemTap,
  });

  final List<MediaItem> items;
  final MediaPickerController controller;
  final ScrollController? scrollController;
  final bool showLoadMore;
  final double autoLoadThreshold;
  final ValueChanged<MediaItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final config = MediaPickerConfig.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ListView.separated(
        key: const PageStorageKey('audio_list'),
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

          final albumName = item.albumName == '<unknown>' ? '' : item.albumName;
          final duration = item.duration ?? 0;

          return ListTile(
            selected: selected,
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.15),
              child: const Icon(Icons.music_note, color: Colors.purple),
            ),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [
                if (albumName.isNotEmpty) albumName,
                if (duration > 0) _formatDuration(duration),
                _formatBytes(item.size),
              ].join(' · '),
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

  static String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
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
}
