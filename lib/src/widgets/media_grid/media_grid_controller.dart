import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'media_grid_loader.dart';

class MediaGridController {
  final DeviceMediaLibrary mediaLibrary = DeviceMediaLibrary();
  final ScrollController? scrollController;
  final MediaPickerTheme theme;
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

  static const int pageSize = 30;

  MediaGridController({
    required this.theme,
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
      if (scrollController!.position.pixels >=
          scrollController!.position.maxScrollExtent - 200) {
        loadMoreMedia();
      }
    });
  }

  Future<void> checkPermissionAndLoadMedia() async {
    try {
      // Сначала проверяем текущее разрешение
      bool permissionChecked = await mediaLibrary.checkPermission();

      // Если разрешения нет и мы еще не запрашиваем - запрашиваем
      if (!permissionChecked && !isRequestingPermission) {
        setState(() {
          isRequestingPermission = true;
        });

        // Запрашиваем разрешение
        permissionChecked = await mediaLibrary.requestPermission();

        setState(() {
          isRequestingPermission = false;
        });
      }

      setState(() {
        hasPermission = permissionChecked;
      });

      // Если разрешение получено - загружаем медиа
      if (hasPermission) {
        await loadMedia(reset: true);
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
      thumbnailCache.clear();
      thumbnailCompleters.clear();
      hasMoreItems = true;
      isLoading = true;
    } else if (isLoadingMore) {
      return;
    }

    setState(() {
      if (reset) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
    });

    try {
      final mediaData = await MediaGridLoader.loadMedia(
        mediaLibrary: mediaLibrary,
        type: mediaType,
        limit: pageSize,
        offset: currentOffset,
        albumId: albumId,
      );

      if (mediaData != null && mediaData.isNotEmpty) {
        final newItems = mediaData.map(MediaItem.fromMap).toList();
        mediaItems.addAll(newItems);
        currentOffset += newItems.length;
        hasMoreItems = newItems.length == pageSize;
        MediaGridLoader.preloadThumbnails(this, newItems);
      } else {
        hasMoreItems = false;
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
          theme: theme,
        ),
      ),
    );
  }

  Widget buildErrorWidget(VoidCallback retry) {
    if (isRequestingPermission) {
      return _buildRequestingPermissionWidget();
    }
    return MediaGridLoader.errorWidget(theme, retry);
  }

  Widget buildLoadingWidget() {
    if (isRequestingPermission) {
      return _buildRequestingPermissionWidget();
    }
    return MediaGridLoader.loadingWidget(theme);
  }

  Widget buildEmptyWidget() => MediaGridLoader.emptyWidget(theme);

  Widget _buildRequestingPermissionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Requesting permission...',
            style: TextStyle(color: theme.textColor, fontSize: 16),
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
