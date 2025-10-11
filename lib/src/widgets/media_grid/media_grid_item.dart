import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'media_grid_helpers.dart';

class MediaGridItem extends StatefulWidget {
  final MediaItem item;
  final bool isSelected;
  final int selectionIndex;
  final Future<Uint8List?> Function() thumbnailFutureBuilder;
  final VoidCallback onThumbnailTap;
  final VoidCallback onSelectionTap;
  final bool enableSelectionOnTap;

  const MediaGridItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.selectionIndex,
    required this.thumbnailFutureBuilder,
    required this.onThumbnailTap,
    required this.onSelectionTap,
    this.enableSelectionOnTap = false,
  });

  @override
  State<MediaGridItem> createState() => _MediaGridItemState();
}

class _MediaGridItemState extends State<MediaGridItem> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = widget.thumbnailFutureBuilder();
  }

  @override
  void didUpdateWidget(MediaGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.id != widget.item.id ||
        oldWidget.thumbnailFutureBuilder != widget.thumbnailFutureBuilder) {
      _thumbnailFuture = widget.thumbnailFutureBuilder();
    }
  }

  void _handleThumbnailTap() {
    if (widget.enableSelectionOnTap) {
      widget.onSelectionTap();
    } else {
      widget.onThumbnailTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = MediaPickerConfig.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!widget.isSelected)
            BoxShadow(
              color: colorScheme.shadow.withAlpha(1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnail(colorScheme),
            _buildSelectionOverlay(config, colorScheme),
            _buildVideoInfo(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _handleThumbnailTap,
      child: Container(
        color: colorScheme.surface.withAlpha(1),
        child: FutureBuilder<Uint8List?>(
          future: _thumbnailFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                cacheWidth: 200,
                cacheHeight: 200,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlaceholder(colorScheme);
            }

            return _buildErrorState(colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface.withAlpha(2),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        widget.item.type == 'video' ? Icons.videocam : Icons.photo,
        color: colorScheme.onSurface.withAlpha(3),
        size: 28,
      ),
    );
  }

  Widget _buildSelectionOverlay(
    MediaPickerConfig config,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: widget.isSelected
            ? Border.all(color: config.selectedColor, width: 3)
            : null,
      ),
      child: _buildSelectionIndicator(config, colorScheme),
    );
  }

  Widget _buildSelectionIndicator(
    MediaPickerConfig config,
    ColorScheme colorScheme,
  ) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: widget.onSelectionTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? config.selectedColor
                : colorScheme.surface.withAlpha(9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: widget.isSelected
              ? Center(
                  child: Text(
                    '${widget.selectionIndex}',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Icon(
                  Icons.circle_outlined,
                  size: 20,
                  color: colorScheme.onSurface.withAlpha(6),
                ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo(ColorScheme colorScheme) {
    if (widget.item.type != 'video') return const SizedBox();

    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.surface.withAlpha(8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: colorScheme.onSurface, size: 12),
            const SizedBox(width: 2),
            Text(
              formatDuration(widget.item.duration ?? 0),
              style: TextStyle(
                color: colorScheme.onSurface,
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
