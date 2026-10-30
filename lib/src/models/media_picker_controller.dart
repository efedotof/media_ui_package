import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:device_media_library/device_media_library.dart';

import 'audio_item.dart';
import 'media_filter.dart';
import 'media_item.dart';
import 'media_picker_exception.dart';
import 'media_picker_result.dart';
import 'media_source.dart';
import 'selected_media_item.dart';

class MediaPickerController extends ChangeNotifier {
  MediaPickerController({
    required this.source,
    this.mediaFilter = MediaFilter.all,
    int? pageSize,
    this.multiSelect = true,
    this.recursive = false,
    DeviceMediaLibrary? library,
  }) : _pageSize = pageSize ?? _defaultPageSizeFor(source),
       _lib = library ?? DeviceMediaLibrary();

  final DeviceMediaLibrary _lib;
  final MediaSource source;
  final MediaFilter mediaFilter;
  final int _pageSize;
  final bool multiSelect;
  final bool recursive;

  int get pageSize => _pageSize;

  static int _defaultPageSizeFor(MediaSource source) {
    switch (source) {
      case MediaSource.device:
        return 200;
      case MediaSource.downloads:
      case MediaSource.documents:
      case MediaSource.picked:
      case MediaSource.dropped:
      case MediaSource.unknown:
        return 50;
    }
  }

  final List<MediaItem> _buffer = [];
  final Set<String> _bufferIds = {};
  int _visibleCount = 0;
  int _pluginOffset = 0;
  bool _pluginExhausted = false;

  final List<SelectedMediaItem> _selected = [];
  final Set<String> _selectedIds = {};

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _disposed = false;
  MediaPickerException? _error;

  List<MediaItem> get items {
    final n = _visibleCount.clamp(0, _buffer.length);
    return List.unmodifiable(_buffer.sublist(0, n));
  }

  List<SelectedMediaItem> get selected => List.unmodifiable(_selected);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _visibleCount < _buffer.length || !_pluginExhausted;
  bool get isDisposed => _disposed;
  int get selectedCount => _selected.length;
  bool get hasSelection => _selected.isNotEmpty;
  MediaPickerException? get error => _error;
  bool get canSelectMore => multiSelect || _selected.isEmpty;

  bool isSelected(String id) => _selectedIds.contains(id);

  MediaPickerResult get result =>
      MediaPickerResult.fromItems(List.of(_selected));

  Future<void> loadInitial() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _error = null;
    _buffer.clear();
    _bufferIds.clear();
    _visibleCount = 0;
    _pluginOffset = 0;
    _pluginExhausted = false;
    _safeNotify();

    try {
      await _fetchAndAppend();
    } on PlatformException catch (e) {
      _error = MediaPickerException.fromPlatform(e);
    } catch (e) {
      _error = MediaPickerException(code: 'UNKNOWN', message: e.toString());
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> loadMore() async {
    if (_isLoading || _disposed) return false;

    if (_visibleCount < _buffer.length) {
      _visibleCount = (_visibleCount + _pageSize).clamp(0, _buffer.length);
      _safeNotify();
      return true;
    }

    if (_pluginExhausted) return false;

    _isLoading = true;
    _safeNotify();
    try {
      final added = await _fetchAndAppend();
      return added > 0;
    } on PlatformException catch (e) {
      _error = MediaPickerException.fromPlatform(e);
      return false;
    } catch (e) {
      _error = MediaPickerException(code: 'UNKNOWN', message: e.toString());
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing || _disposed) return;
    _isRefreshing = true;
    _safeNotify();
    try {
      await loadInitial();
    } finally {
      _isRefreshing = false;
      _safeNotify();
    }
  }

  Future<int> _fetchAndAppend() async {
    final page = await _fetchPage(offset: _pluginOffset, limit: _pageSize);

    if (page.isEmpty) {
      _pluginExhausted = true;
      return 0;
    }

    int added = 0;
    for (final item in page) {
      if (_bufferIds.add(item.id)) {
        _buffer.add(item);
        added++;
      }
    }

    _pluginOffset += page.length;

    if (page.length < _pageSize) {
      _pluginExhausted = true;
    }
    if (page.length > _pageSize) {
      _pluginExhausted = true;
    }
    if (added == 0) {
      _pluginExhausted = true;
      return 0;
    }

    _visibleCount = (_visibleCount + _pageSize).clamp(0, _buffer.length);
    return added;
  }

  Future<List<MediaItem>> _fetchPage({
    required int offset,
    required int limit,
  }) async {
    List<Map<String, dynamic>>? raw;

    switch (source) {
      case MediaSource.device:
        if (mediaFilter == MediaFilter.audio) {
          raw = await _lib.getAudio(limit: limit, offset: offset);
        } else if (mediaFilter == MediaFilter.image) {
          raw = await _lib.getImages(limit: limit, offset: offset);
        } else if (mediaFilter == MediaFilter.video) {
          raw = await _lib.getVideos(limit: limit, offset: offset);
        } else {
          raw = await _lib.getAllMedia(limit: limit, offset: offset);
        }
        break;
      case MediaSource.downloads:
        raw = await _lib.getDownloads(
          limit: limit,
          offset: offset,
          recursive: recursive,
        );
        break;
      case MediaSource.documents:
        raw = await _lib.getDocuments(
          limit: limit,
          offset: offset,
          recursive: recursive,
        );
        break;
      case MediaSource.picked:
      case MediaSource.dropped:
      case MediaSource.unknown:
        return const [];
    }

    final list = raw ?? const <Map<String, dynamic>>[];
    return list.map<MediaItem>((m) {
      if (mediaFilter == MediaFilter.audio) {
        return AudioItem.fromMap(m).toMediaItem();
      }
      return MediaItem.fromMap(m);
    }).toList();
  }

  void toggleSelection(MediaItem item) {
    if (_selectedIds.contains(item.id)) {
      deselect(item.id);
      return;
    }
    if (!multiSelect) {
      _selectedIds.clear();
      _selected.clear();
    } else if (!canSelectMore) {
      return;
    }
    _selectedIds.add(item.id);
    _selected.add(SelectedMediaItem.fromMediaItem(item, source: source));
    _safeNotify();
  }

  void select(MediaItem item) {
    if (_selectedIds.contains(item.id)) return;
    if (!multiSelect) {
      _selectedIds
        ..clear()
        ..add(item.id);
      _selected
        ..clear()
        ..add(SelectedMediaItem.fromMediaItem(item, source: source));
    } else {
      if (!canSelectMore) return;
      _selectedIds.add(item.id);
      _selected.add(SelectedMediaItem.fromMediaItem(item, source: source));
    }
    _safeNotify();
  }

  void deselect(String id) {
    if (_selectedIds.remove(id)) {
      _selected.removeWhere((e) => e.id == id);
      _safeNotify();
    }
  }

  void clearSelection() {
    if (_selectedIds.isEmpty) return;
    _selectedIds.clear();
    _selected.clear();
    _safeNotify();
  }

  void selectAll() {
    if (!multiSelect) return;
    for (final item in items) {
      if (!_selectedIds.contains(item.id)) {
        _selectedIds.add(item.id);
        _selected.add(SelectedMediaItem.fromMediaItem(item, source: source));
      }
    }
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void addItems(List<MediaItem> newItems) {
    if (_disposed) return;

    int added = 0;
    for (final item in newItems) {
      if (_bufferIds.add(item.id)) {
        _buffer.add(item);
        added++;
      }
    }

    if (added > 0) {
      _visibleCount = _buffer.length;
      _pluginExhausted = true;
      _safeNotify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
