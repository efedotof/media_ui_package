import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';
import "selection_overlay.dart";
import 'select_indicator.dart';
import 'thumbnail_or_icon.dart';

class MediaTile extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final bool multiSelect;
  final int thumbnailSize;
  final VoidCallback onTap;

  const MediaTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.multiSelect,
    required this.thumbnailSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = MediaPickerConfig.of(context);
    final radius = BorderRadius.circular(config.borderRadius);
    final type = item.type;
    final duration = item.duration ?? 0;
    final name = item.name;
    final isVideo = type == 'video';

    return ClipRRect(
      borderRadius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ThumbnailOrIcon(
                mediaId: item.id,
                mediaType: type,
                size: thumbnailSize,
                isVideo: isVideo,
              ),
              if (multiSelect)
                Positioned(
                  top: 4,
                  right: 4,
                  child: SelectIndicator(selected: isSelected, compact: true),
                )
              else if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.check_circle, color: config.selectedColor),
                ),
              if (isSelected)
                SelectionOverlayMediaPickerUi(color: config.selectedColor),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: isVideo ? Colors.black54 : Colors.black45,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    isVideo && duration > 0
                        ? '${_formatDuration(duration)} · $name'
                        : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }
}
