import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'full_screen_media_view.dart';

class MediaGrid extends StatefulWidget {
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final MediaPickerTheme theme;
  final bool showVideos;
  final ScrollController? scrollController;
  final Future<Uint8List?> Function(MediaItem)? thumbnailBuilder;

  const MediaGrid({
    super.key,
    required this.selectedItems,
    required this.onItemSelected,
    required this.theme,
    this.showVideos = true,
    this.scrollController,
    this.thumbnailBuilder,
  });

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  List<MediaItem> _mediaItems = [];
  final double _gridSpacing = 1.5;
  final Map<String, Uint8List?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _mediaItems = List.generate(
        50,
        (index) => MediaItem(
          id: '$index',
          name: 'Media $index',
          path: '',
          dateAdded: DateTime.now().millisecondsSinceEpoch,
          size: 0,
          width: 100,
          height: 100,
          albumId: '1',
          albumName: 'Camera',
          type: index % 4 == 0 ? 'video' : 'image',
          duration: index % 4 == 0 ? 60000 : null,
        ),
      );
    });

    // Предзагрузка thumbnail'ов
    if (widget.thumbnailBuilder != null) {
      for (final item in _mediaItems) {
        _loadThumbnail(item);
      }
    }
  }

  Future<void> _loadThumbnail(MediaItem item) async {
    if (_thumbnailCache.containsKey(item.id)) return;

    try {
      final thumbnail = await widget.thumbnailBuilder!(item);
      if (thumbnail != null) {
        setState(() {
          _thumbnailCache[item.id] = thumbnail;
        });
      }
    } catch (e) {
      // Игнорируем ошибки загрузки thumbnail'ов
    }
  }

  bool _isSelected(MediaItem item) {
    return widget.selectedItems.any((selected) => selected.id == item.id);
  }

  int _getSelectionIndex(MediaItem item) {
    return widget.selectedItems.indexWhere(
          (selected) => selected.id == item.id,
        ) +
        1;
  }

  void _openFullScreenView(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMediaView(
          mediaItems: _mediaItems,
          initialIndex: index,
          selectedItems: widget.selectedItems,
          onItemSelected: widget.onItemSelected,
          theme: widget.theme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMedia,
      child: GridView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.all(_gridSpacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: _gridSpacing,
          mainAxisSpacing: _gridSpacing,
          childAspectRatio: 1,
        ),
        itemCount: _mediaItems.length,
        itemBuilder: (context, index) {
          final item = _mediaItems[index];
          final isSelected = _isSelected(item);
          final selectionIndex = _getSelectionIndex(item);

          return _MediaGridItem(
            item: item,
            isSelected: isSelected,
            selectionIndex: selectionIndex,
            theme: widget.theme,
            thumbnail: _thumbnailCache[item.id],
            onThumbnailTap: () => _openFullScreenView(index),
            onSelectionTap: () {
              widget.onItemSelected(item, !isSelected);
            },
          );
        },
      ),
    );
  }
}

class _MediaGridItem extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final int selectionIndex;
  final MediaPickerTheme theme;
  final Uint8List? thumbnail;
  final VoidCallback onThumbnailTap;
  final VoidCallback onSelectionTap;

  const _MediaGridItem({
    required this.item,
    required this.isSelected,
    required this.selectionIndex,
    required this.theme,
    required this.thumbnail,
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: thumbnail != null
                ? Image.memory(
                    thumbnail!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),

        if (isSelected)
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.primaryColor, width: 3),
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
                color: isSelected
                    ? theme.primaryColor
                    : Colors.white.withAlpha(200),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.primaryColor : Colors.white,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Text(
                        '$selectionIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  Icon(Icons.play_arrow, color: Colors.white, size: 12),
                  SizedBox(width: 2),
                  Text(
                    _formatDuration(item.duration ?? 0),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        item.type == 'video' ? Icons.videocam : Icons.photo,
        color: Colors.grey[600],
        size: 32,
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
