import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'media_grid_loader.dart';

class MediaGridController {
  final DeviceMediaLibrary mediaLibrary = DeviceMediaLibrary();
  final ScrollController? scrollController;
  final MediaType mediaType;
  final String? albumId;
  final Function(MediaItem, bool) onItemSelected;
  final List<MediaItem> selectedItems;
  final Uint8List? Function(MediaItem)? thumbnailBuilder;
  final VoidCallback onUpdate;
  final bool showSelectionIndicators;
  final List<MediaItem> mediaItems = [];
  final Map<String, Uint8List?> thumbnailCache = {};
  final Map<String, bool> thumbnailLoading = {};

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreItems = true;
  bool hasPermission = false;
  bool isRequestingPermission = false;
  int currentOffset = 0;
  bool _isDisposed = false;

  static const int pageSize = 50;
  static const int preloadThreshold = 100;
  static const int preloadAheadItems = 10;

  MediaGridController({
    required this.mediaType,
    required this.albumId,
    required this.thumbnailBuilder,
    required this.scrollController,
    required this.onItemSelected,
    required this.selectedItems,
    required this.onUpdate,
    this.showSelectionIndicators = true,
  });

  Future<void> init() async {
    await checkPermissionAndLoadMedia();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    scrollController?.addListener(() {
      if (_isDisposed) return;

      final maxScroll = scrollController!.position.maxScrollExtent;
      final currentScroll = scrollController!.position.pixels;

      if (maxScroll - currentScroll <= preloadThreshold) {
        loadMoreMedia();
      }
    });
  }

  bool? _permissionCache;
  Future<void> checkPermissionAndLoadMedia() async {
    try {
      _permissionCache ??= await mediaLibrary.checkPermission();
      bool permissionChecked = _permissionCache!;

      debugPrint('Permission checked: $permissionChecked');

      if (!permissionChecked && !isRequestingPermission) {
        debugPrint('Requesting permission...');
        setState(() {
          isRequestingPermission = true;
        });

        permissionChecked = await mediaLibrary.requestPermission();
        _permissionCache = permissionChecked;
        debugPrint('Permission granted: $permissionChecked');

        setState(() {
          isRequestingPermission = false;
        });
      }

      setState(() {
        hasPermission = permissionChecked;
      });

      if (hasPermission) {
        debugPrint('Loading media with permission...');
        await loadMedia(reset: true);
      } else {
        debugPrint('No permission granted');
      }
    } catch (e) {
      debugPrint('Error checking permission: $e');
      setState(() {
        isRequestingPermission = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMedia({bool reset = false}) async {
    if (_isDisposed) return;

    if (reset) {
      currentOffset = 0;
      mediaItems.clear();
      _cleanupThumbnailCache();
      hasMoreItems = true;
      setState(() {
        isLoading = true;
      });
    } else if (isLoadingMore) {
      return;
    } else {
      setState(() {
        isLoadingMore = true;
      });
    }

    try {
      debugPrint(
        'Loading media: type=$mediaType, limit=$pageSize, offset=$currentOffset, albumId=$albumId',
      );

      final mediaData = await MediaGridLoader.loadMedia(
        mediaLibrary: mediaLibrary,
        type: mediaType,
        limit: pageSize,
        offset: currentOffset,
        albumId: albumId,
      );

      debugPrint('Media data received: ${mediaData?.length} items');

      if (mediaData != null && mediaData.isNotEmpty) {
        final newItems = mediaData.map(MediaItem.fromMap).toList();
        debugPrint('Converted to ${newItems.length} MediaItems');

        setState(() {
          mediaItems.addAll(newItems);
          currentOffset += newItems.length;
          hasMoreItems = newItems.length == pageSize;
        });

        _preloadThumbnailsSmart(newItems);
      } else {
        debugPrint('No media data received or empty');
        setState(() {
          hasMoreItems = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading media: $e');
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _preloadThumbnailsSmart(List<MediaItem> newItems) {
    if (_isDisposed || newItems.isEmpty) return;

    final firstBatch = newItems.take(12).toList();
    _loadThumbnailsBatch(firstBatch);
    if (newItems.length > 12) {
      final remainingBatch = newItems.skip(12).toList();
      Future.microtask(() {
        if (!_isDisposed) {
          _loadThumbnailsBatch(remainingBatch);
        }
      });
    }
  }

  void _loadThumbnailsBatch(List<MediaItem> items) {
    for (final item in items) {
      if (!thumbnailCache.containsKey(item.id) &&
          !thumbnailLoading.containsKey(item.id)) {
        loadThumbnail(item);
      }
    }
  }

  void loadThumbnail(MediaItem item) {
    if (_isDisposed || thumbnailLoading[item.id] == true) return;

    setState(() {
      thumbnailLoading[item.id] = true;
    });

    Future.microtask(() async {
      try {
        Uint8List? thumbnail;

        if (thumbnailBuilder != null) {
          thumbnail = thumbnailBuilder!(item);
        } else {
          thumbnail = await mediaLibrary.getThumbnail(
            mediaId: item.id,
            mediaType: item.type,
            width: 200,
            height: 200,
          );
        }

        if (!_isDisposed) {
          setState(() {
            if (thumbnail != null) {
              thumbnailCache[item.id] = thumbnail;
            }
            thumbnailLoading.remove(item.id);
          });
        }
      } catch (e) {
        debugPrint('Error loading thumbnail for ${item.id}: $e');
        if (!_isDisposed) {
          setState(() {
            thumbnailLoading.remove(item.id);
          });
        }
      }
    });
  }

  void _cleanupThumbnailCache() {
    final currentIds = mediaItems.map((item) => item.id).toSet();
    thumbnailCache.removeWhere((key, value) => !currentIds.contains(key));
    thumbnailLoading.removeWhere((key, value) => !currentIds.contains(key));
  }

  Future<void> loadMoreMedia() async {
    if (_isDisposed) return;
    if (hasMoreItems && !isLoadingMore && !isLoading) {
      await loadMedia(reset: false);
    }
  }

  Uint8List? getThumbnail(MediaItem item) {
    return thumbnailCache[item.id];
  }

  bool isThumbnailLoading(MediaItem item) {
    return thumbnailLoading[item.id] == true;
  }

  void openFullScreenView(BuildContext context, int index) {
    if (_isDisposed) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenMediaView(
          mediaItems: mediaItems,
          initialIndex: index,
          selectedItems: selectedItems,
          onItemSelected: onItemSelected,
          showSelectionIndicators: showSelectionIndicators,
        ),
      ),
    );
  }

  void setState(VoidCallback fn) {
    if (_isDisposed) return;
    fn();
    onUpdate();
  }

  void dispose() {
    _isDisposed = true;
  }
}
