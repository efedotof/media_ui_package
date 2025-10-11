import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'fullscreen_media_loader.dart';

class FullScreenMediaController {
  final List<MediaItem> mediaItems;
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;
  final VoidCallback onUpdate;

  final PageController pageController;
  final Map<String, Uint8List?> imageCache = {};
  final DeviceMediaLibrary _mediaLibrary = DeviceMediaLibrary();

  int currentIndex;
  bool _isDisposed = false;

  FullScreenMediaController({
    required this.mediaItems,
    required this.initialIndex,
    required this.selectedItems,
    required this.onItemSelected,
    required this.onUpdate,
  }) : currentIndex = initialIndex,
       pageController = PageController(initialPage: initialIndex) {
    _preloadImages();
  }

  final int initialIndex;

  void _preloadImages() {
    if (_isDisposed) return;

    final indices = [
      currentIndex,
      currentIndex - 1,
      currentIndex + 1,
    ].where((index) => index >= 0 && index < mediaItems.length);

    for (final i in indices) {
      FullScreenMediaLoader.loadFullImage(
        mediaLibrary: _mediaLibrary,
        item: mediaItems[i],
        cache: imageCache,
        onLoaded: () {
          if (!_isDisposed) onUpdate();
        },
      );
    }
  }

  void onPageChanged(int index) {
    if (_isDisposed) return;

    currentIndex = index;
    _preloadImages();
    onUpdate();
  }

  bool isSelected(MediaItem item) =>
      selectedItems.any((selected) => selected.id == item.id);

  int getSelectionIndex(MediaItem item) =>
      selectedItems.indexWhere((selected) => selected.id == item.id) + 1;

  void toggleSelection() {
    if (_isDisposed) return;

    final currentItem = mediaItems[currentIndex];
    final selected = isSelected(currentItem);
    onItemSelected(currentItem, !selected);
    onUpdate();
  }

  void dispose() {
    _isDisposed = true;
    pageController.dispose();
  }
}
