import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
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

  static const int _pageSize = 100;
  static const int _thumbnailPreloadCount = 20;

  bool _hasPermission = false;
  bool _isLoadingMedia = false;
  int _currentOffset = 0;

  final List<MediaItem> _mediaItems = [];
  final Map<String, Uint8List?> _thumbnailsCache = {};
  final List<MediaItem> _selectedItems = [];
  final Map<String, Completer<Uint8List?>> _thumbnailCompleters = {};
  final Map<String, bool> _thumbnailErrors = {};

  MediaGridCubit({
    required this.mediaType,
    required this.albumId,
    this.thumbnailBuilder,
    this.allowMultiple = true,
    this.maxSelection = 10,
    this.initialSelection = const [],
  }) : super(const MediaGridState.initial()) {
    _selectedItems.addAll(initialSelection);
  }

  List<MediaItem> get selectedItems => List.unmodifiable(_selectedItems);

  Future<void> init() async => checkPermissionAndLoadMedia();

  void clearSelection() {
    if (_selectedItems.isEmpty) return;
    _selectedItems.clear();
    if (state is _Loaded) {
      _emitLoaded(hasMore: (state as _Loaded).hasMoreItems);
    }
  }

  Future<void> checkPermissionAndLoadMedia() async {
    emit(const MediaGridState.permissionRequesting());

    try {
      final hasPermission = await _mediaLibrary.checkPermission();

      if (!hasPermission) {
        _hasPermission = await _mediaLibrary.requestPermission();
      } else {
        _hasPermission = true;
      }

      if (_hasPermission) {
        await loadMedia(reset: true);
      } else {
        emit(const MediaGridState.permissionDenied());
      }
    } catch (e, st) {
      debugPrint('Permission error: $e');
      debugPrintStack(stackTrace: st);
      emit(MediaGridState.error(message: 'Permission error: $e'));
    }
  }

  void toggleSelection(MediaItem mediaItem) {
    if (_selectedItems.contains(mediaItem)) {
      _selectedItems.remove(mediaItem);
    } else {
      if (allowMultiple && _selectedItems.length < maxSelection) {
        _selectedItems.add(mediaItem);
      } else if (!allowMultiple) {
        _selectedItems
          ..clear()
          ..add(mediaItem);
      }
    }
    _emitLoaded();
  }

  Future<void> loadMedia({bool reset = false}) async {
    if (_isLoadingMedia) return;
    _isLoadingMedia = true;

    try {
      if (reset) {
        _currentOffset = 0;
        _mediaItems.clear();
        _thumbnailsCache.clear();
        _thumbnailCompleters.clear();
        _thumbnailErrors.clear();
        emit(const MediaGridState.loading());
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
      debugPrint('Load media error: $e');
      debugPrintStack(stackTrace: st);
      emit(MediaGridState.error(message: 'Load error: $e'));
    } finally {
      _isLoadingMedia = false;
    }
  }

  Future<List<Map<String, dynamic>>?> _fetchMedia({
    required int limit,
    required int offset,
    String? albumId,
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
    } catch (e) {
      debugPrint('Error fetching media: $e');
      return null;
    }
  }

  void _emitLoaded({bool hasMore = true}) {
    emit(
      MediaGridState.loaded(
        mediaItems: List.unmodifiable(_mediaItems),
        thumbnailCache: Map.unmodifiable(_thumbnailsCache),
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

    final itemsToPreload = newItems
        .where(
          (item) =>
              !_thumbnailsCache.containsKey(item.id) &&
              !_thumbnailCompleters.containsKey(item.id) &&
              !_thumbnailErrors.containsKey(item.id),
        )
        .take(_thumbnailPreloadCount)
        .toList();

    for (final item in itemsToPreload) {
      _loadThumbnail(item);
    }
  }

  void _loadThumbnail(MediaItem item) {
    if (_thumbnailsCache.containsKey(item.id) ||
        _thumbnailCompleters.containsKey(item.id) ||
        _thumbnailErrors.containsKey(item.id)) {
      return;
    }

    final completer = Completer<Uint8List?>();
    _thumbnailCompleters[item.id] = completer;

    Future<Uint8List?> thumbnailFuture;
    if (thumbnailBuilder != null) {
      thumbnailFuture = Future(() => thumbnailBuilder!(item));
    } else {
      thumbnailFuture = _mediaLibrary.getThumbnail(
        mediaId: item.id,
        mediaType: item.type,
        width: 200,
        height: 200,
      );
    }

    thumbnailFuture
        .then((thumbnail) {
          if (thumbnail != null) {
            _thumbnailsCache[item.id] = thumbnail;
            _thumbnailErrors.remove(item.id);
          } else {
            _thumbnailErrors[item.id] = true;
          }
          completer.complete(thumbnail);
          _thumbnailCompleters.remove(item.id);

          if (thumbnail != null && state is _Loaded && !isClosed) {
            final current = state as _Loaded;
            emit(
              current.copyWith(
                thumbnailCache: Map.unmodifiable(_thumbnailsCache),
              ),
            );
          }
        })
        .catchError((error, stackTrace) {
          debugPrint('Error loading thumbnail for ${item.id}: $error');
          _thumbnailErrors[item.id] = true;
          completer.complete(null);
          _thumbnailCompleters.remove(item.id);
        });
  }

  Future<Uint8List?> getThumbnailFuture(MediaItem item) async {
    if (_thumbnailsCache.containsKey(item.id)) {
      return _thumbnailsCache[item.id];
    }

    if (_thumbnailCompleters.containsKey(item.id)) {
      return await _thumbnailCompleters[item.id]!.future;
    }

    if (_thumbnailErrors.containsKey(item.id)) {
      return null;
    }

    _loadThumbnail(item);
    return await _thumbnailCompleters[item.id]?.future;
  }

  Future<void> loadVisibleThumbnails(List<MediaItem> visibleItems) async {
    for (final item in visibleItems) {
      if (!_thumbnailsCache.containsKey(item.id) &&
          !_thumbnailCompleters.containsKey(item.id) &&
          !_thumbnailErrors.containsKey(item.id)) {
        _loadThumbnail(item);
      }
    }
  }

  Uint8List? getThumbnail(MediaItem item) => _thumbnailsCache[item.id];
  bool isThumbnailLoading(MediaItem item) =>
      _thumbnailCompleters.containsKey(item.id);
  bool isSelected(MediaItem item) => _selectedItems.contains(item);
  int getSelectionIndex(MediaItem item) => _selectedItems.indexOf(item) + 1;

  Future<void> loadTumbunail(MediaItem item) async {
    _thumbnailErrors.remove(item.id);
    _thumbnailsCache.remove(item.id);
    _thumbnailCompleters.remove(item.id);
    _loadThumbnail(item);
  }

  bool hasThumbnailError(MediaItem item) =>
      _thumbnailErrors.containsKey(item.id);
  bool isThumbnailLoaded(MediaItem item) =>
      _thumbnailsCache.containsKey(item.id);
}
