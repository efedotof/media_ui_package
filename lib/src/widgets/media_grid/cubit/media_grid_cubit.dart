import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

part 'media_grid_state.dart';
part 'media_grid_cubit.freezed.dart';

class MediaGridCubit extends Cubit<MediaGridState> {
  final DeviceMediaLibrary _mediaLibrary = DeviceMediaLibrary();
  final MediaType mediaType;
  final String? albumId;
  final Uint8List? Function(MediaItem)? thumbnailBuilder;
  final bool allowMultiple;
  final int maxSelection;
  final List<MediaItem> initialSelection;

  static const int _pageSize = 50;
  static const int _thumbnailPreloadCount = 12;

  bool _hasPermission = false;
  bool _isRequestingPermission = false;
  bool _isLoadingMedia = false;
  int _currentOffset = 0;

  final List<MediaItem> _mediaItems = [];
  final Map<String, Uint8List?> _thumbnailCache = {};
  final Map<String, bool> _thumbnailLoading = {};
  final List<MediaItem> _selectedItems = [];

  MediaGridCubit({
    required this.mediaType,
    required this.albumId,
    required this.thumbnailBuilder,
    this.allowMultiple = true,
    this.maxSelection = 10,
    this.initialSelection = const [],
  }) : super(const MediaGridState.initial()) {
    _selectedItems.addAll(initialSelection);
  }

  List<MediaItem> get selectedItems => List.unmodifiable(_selectedItems);

  Future<void> init() async => checkPermissionAndLoadMedia();

  Future<void> checkPermissionAndLoadMedia() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;

    emit(const MediaGridState.permissionRequesting());

    try {
      _hasPermission = await _mediaLibrary.checkPermission() || 
                      await _mediaLibrary.requestPermission();

      if (_hasPermission) {
        await loadMedia(reset: true);
      } else {
        emit(const MediaGridState.permissionDenied());
      }
    } catch (e, st) {
      debugPrintStack(label: 'Permission error', stackTrace: st);
      emit(MediaGridState.error(message: 'Permission error: $e'));
    } finally {
      _isRequestingPermission = false;
    }
  }

  void toggleSelection(MediaItem mediaItem) {
    final isCurrentlySelected = _selectedItems.contains(mediaItem);

    if (isCurrentlySelected) {
      _selectedItems.remove(mediaItem);
    } else {
      if (allowMultiple) {
        if (_selectedItems.length < maxSelection) {
          _selectedItems.add(mediaItem);
        }
        // Если достигнут лимит, можно показать уведомление
      } else {
        _selectedItems.clear();
        _selectedItems.add(mediaItem);
      }
    }

    // Обновляем состояние
    if (state is _Loaded) {
      _emitLoaded(hasMore: (state as _Loaded).hasMoreItems);
    }
  }

  void clearSelection() {
    _selectedItems.clear();
    if (state is _Loaded) {
      _emitLoaded(hasMore: (state as _Loaded).hasMoreItems);
    }
  }

  Future<void> loadMedia({bool reset = false}) async {
    if (_isLoadingMedia) return;
    _isLoadingMedia = true;

    try {
      if (reset) {
        _currentOffset = 0;
        _mediaItems.clear();
        _thumbnailCache.clear();
        _thumbnailLoading.clear();
        emit(const MediaGridState.loading());
      } else if (state is _Loaded) {
        emit((state as _Loaded).copyWith(isLoadingMore: true));
      }

      final mediaData = await _fetchMedia(
        limit: _pageSize,
        offset: _currentOffset,
        albumId: albumId,
      );

      if (mediaData == null || mediaData.isEmpty) {
        _emitLoaded(hasMore: false);
        return;
      }

      final newItems = mediaData.map(MediaItem.fromMap).toList();
      _mediaItems.addAll(newItems);
      _currentOffset += newItems.length;

      _emitLoaded(hasMore: newItems.length == _pageSize);
      _preloadThumbnails(newItems);
    } catch (e, st) {
      debugPrintStack(label: 'Load media error', stackTrace: st);
      emit(MediaGridState.error(message: 'Load error: $e'));
    } finally {
      _isLoadingMedia = false;
    }
  }

  Future<List<Map<String, dynamic>>?> _fetchMedia({
    required int limit,
    required int offset,
    required String? albumId,
  }) async {
    try {
      switch (mediaType) {
        case MediaType.images:
          return _mediaLibrary.getImages(
            limit: limit,
            offset: offset,
            albumId: albumId,
          );
        case MediaType.videos:
          return _mediaLibrary.getVideos(
            limit: limit,
            offset: offset,
            albumId: albumId,
          );
        case MediaType.all:
          return _mediaLibrary.getAllMedia(
            limit: limit,
            offset: offset,
            albumId: albumId,
          );
      }
    } catch (e, st) {
      debugPrint('Error fetching media: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  void _emitLoaded({required bool hasMore}) {
    emit(
      MediaGridState.loaded(
        mediaItems: List.unmodifiable(_mediaItems),
        thumbnailCache: Map.unmodifiable(_thumbnailCache),
        hasMoreItems: hasMore,
        currentOffset: _currentOffset,
        isLoadingMore: false,
        showSelectionIndicators: true,
        selectedMediaItems: List.unmodifiable(_selectedItems),
      ),
    );
  }

  void _preloadThumbnails(List<MediaItem> newItems) {
    if (newItems.isEmpty) return;

    final firstBatch = newItems.take(_thumbnailPreloadCount).toList();
    for (final item in firstBatch) {
      _loadThumbnail(item);
    }

    if (newItems.length > _thumbnailPreloadCount) {
      Future.microtask(() {
        for (final item in newItems.skip(_thumbnailPreloadCount)) {
          _loadThumbnail(item);
        }
      });
    }
  }

  Future<void> _loadThumbnail(MediaItem item) async {
    if (_thumbnailCache.containsKey(item.id) || _thumbnailLoading[item.id] == true) {
      return;
    }
    _thumbnailLoading[item.id] = true;

    try {
      final thumbnail = await _getThumbnailFor(item);
      if (thumbnail != null) {
        _thumbnailCache[item.id] = thumbnail;
        if (state is _Loaded) {
          emit(
            (state as _Loaded).copyWith(
              thumbnailCache: Map.unmodifiable(_thumbnailCache),
            ),
          );
        }
      }
    } catch (e, st) {
      debugPrintStack(label: 'Thumbnail error', stackTrace: st);
    } finally {
      _thumbnailLoading.remove(item.id);
    }
  }

  Future<Uint8List?> _getThumbnailFor(MediaItem item) async {
    if (thumbnailBuilder != null) return thumbnailBuilder!(item);
    return _mediaLibrary.getThumbnail(
      mediaId: item.id,
      mediaType: item.type,
      width: 200,
      height: 200,
    );
  }

  String formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  // Public methods
  Uint8List? getThumbnail(MediaItem item) => _thumbnailCache[item.id];
  bool isThumbnailLoading(MediaItem item) => _thumbnailLoading[item.id] ?? false;
  bool isSelected(MediaItem item) => _selectedItems.contains(item);
  int getSelectionIndex(MediaItem item) => _selectedItems.indexOf(item) + 1;
}