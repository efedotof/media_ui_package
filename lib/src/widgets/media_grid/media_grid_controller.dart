import 'dart:async';
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
  final Future<Uint8List?> Function(MediaItem)? thumbnailBuilder;
  final VoidCallback onUpdate;

  final List<MediaItem> mediaItems = [];
  final Map<String, Uint8List?> thumbnailCache = {};
  final Map<String, Completer<Uint8List?>> thumbnailCompleters = {};

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreItems = true;
  bool hasPermission = false;
  bool isRequestingPermission = false;
  int currentOffset = 0;

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
  });

  Future<void> init() async {
    await checkPermissionAndLoadMedia();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    scrollController?.addListener(() {
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
        // Загружаем первую страницу сразу
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
    if (reset) {
      currentOffset = 0;
      mediaItems.clear();
      // Не очищаем полностью кэш, только устаревшие элементы
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

        // Оптимизация: предзагрузка миниатюр в фоне с приоритетом для видимых элементов
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
    if (newItems.isEmpty) return;

    final firstBatch = newItems.take(12).toList();
    MediaGridLoader.preloadThumbnails(this, firstBatch);

    if (newItems.length > 12) {
      final remainingBatch = newItems.skip(12).toList();
      Future.delayed(const Duration(milliseconds: 300), () {
        MediaGridLoader.preloadThumbnails(this, remainingBatch);
      });
    }
  }

  void _cleanupThumbnailCache() {
    final currentIds = mediaItems.map((item) => item.id).toSet();
    thumbnailCache.removeWhere((key, value) => !currentIds.contains(key));
    thumbnailCompleters.removeWhere((key, value) => !currentIds.contains(key));
  }

  Future<void> loadMoreMedia() async {
    if (hasMoreItems && !isLoadingMore && !isLoading) {
      await loadMedia(reset: false);
    }
  }

  Future<Uint8List?> getThumbnailFuture(MediaItem item) async {
    return await MediaGridLoader.getThumbnailFuture(this, item);
  }

  void openFullScreenView(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenMediaView(
          mediaItems: mediaItems,
          initialIndex: index,
          selectedItems: selectedItems,
          onItemSelected: onItemSelected,
        ),
      ),
    );
  }

  Widget buildErrorWidget(BuildContext context, VoidCallback retry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isRequestingPermission) {
      return _buildRequestingPermissionWidget(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.onSurface.withAlpha(5),
          ),
          const SizedBox(height: 16),
          Text(
            'Permission Required',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This app needs access to your photos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withAlpha(7)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingWidget(BuildContext context) {
    final theme = Theme.of(context);

    if (isRequestingPermission) {
      return _buildRequestingPermissionWidget(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading media...',
            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(7)),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 64,
            color: colorScheme.onSurface.withAlpha(5),
          ),
          const SizedBox(height: 16),
          Text(
            'No media found',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestingPermissionWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Requesting permission...',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void setState(VoidCallback fn) {
    fn();
    onUpdate();
  }

  void dispose() {
    scrollController?.dispose();
  }
}
