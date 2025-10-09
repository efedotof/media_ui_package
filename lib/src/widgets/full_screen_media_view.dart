import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class FullScreenMediaView extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final MediaPickerTheme theme;

  const FullScreenMediaView({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    required this.selectedItems,
    required this.onItemSelected,
    required this.theme,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
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

  void _toggleSelection() {
    final currentItem = widget.mediaItems[_currentIndex];
    final isSelected = _isSelected(currentItem);
    widget.onItemSelected(currentItem, !isSelected);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.mediaItems[index];
              return InteractiveViewer(
                panEnabled: false,
                minScale: 1.0,
                maxScale: 3.0,
                child: Center(
                  child: item.type == 'video'
                      ? _buildVideoWidget(item)
                      : _buildImageWidget(item),
                ),
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleSelection,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _isSelected(widget.mediaItems[_currentIndex])
                    ? Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${_getSelectionIndex(widget.mediaItems[_currentIndex])}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          if (widget.mediaItems.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.mediaItems.length}',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(MediaItem item) {
    return Container(
      width: double.infinity,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo, color: Colors.grey[600], size: 64),
          SizedBox(height: 16),
          Text('Image: ${item.name}', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildVideoWidget(MediaItem item) {
    return Container(
      width: double.infinity,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, color: Colors.grey[600], size: 64),
          SizedBox(height: 16),
          Text('Video: ${item.name}', style: TextStyle(color: Colors.white)),
          SizedBox(height: 8),
          Text(
            'Duration: ${_formatDuration(item.duration ?? 0)}',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
