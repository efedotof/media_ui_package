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
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    if (item.type != 'video') return const SizedBox();

    final duration = formatDuration(item.duration ?? 0);

    return Positioned(
      bottom: 6,
      left: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow, size: 12, color: Colors.white),
              const SizedBox(width: 3),
              Text(
                duration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
