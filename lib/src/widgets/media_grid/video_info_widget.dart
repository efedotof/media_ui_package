import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class VideoInfoWidget extends StatelessWidget {
  final MediaItem item;
  final ColorScheme colorScheme;

  const VideoInfoWidget({
    super.key,
    required this.item,
    required this.colorScheme,
  });

  String formatDuration(int milliseconds) {
    final d = Duration(milliseconds: milliseconds);
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (item.type != 'video') return const SizedBox();

    final duration = formatDuration(item.duration ?? 0);

    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.scrim,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          duration,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
