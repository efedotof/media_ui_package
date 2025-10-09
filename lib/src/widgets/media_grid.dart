import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class MediaGrid extends StatefulWidget {
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final MediaPickerTheme theme;
  final bool showVideos;
  final ScrollController? scrollController;

  const MediaGrid({
    super.key,
    required this.selectedItems,
    required this.onItemSelected,
    required this.theme,
    this.showVideos = true,
    this.scrollController,
  });

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  List<MediaItem> _mediaItems = [];
  final double _gridSpacing = 1.5;

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
  }

  bool _isSelected(MediaItem item) {
    return widget.selectedItems.any((selected) => selected.id == item.id);
  }

  int _getSelectionIndex(MediaItem item) {
    return widget.selectedItems
            .indexWhere((selected) => selected.id == item.id) +
        1;
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
            onTap: () {
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
  final VoidCallback onTap;

  const _MediaGridItem({
    required this.item,
    required this.isSelected,
    required this.selectionIndex,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                item.type == 'video' ? Icons.videocam : Icons.photo,
                color: Colors.grey[600],
                size: 32,
              ),
            ),
          ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primaryColor,
                  width: 3,
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$selectionIndex',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  color: Colors.black.withAlpha(7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '1:30',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
