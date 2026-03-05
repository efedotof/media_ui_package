import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:device_media_library/device_media_library.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'package:http/http.dart' as http;
part 'full_screen_media_state.dart';
part 'full_screen_media_cubit.freezed.dart';

class FullScreenMediaCubit extends Cubit<FullScreenMediaState> {
  final DeviceMediaLibrary _mediaLibrary = DeviceMediaLibrary();
  final List<MediaItem> mediaItems;
  final Function(MediaItem, bool) onItemSelected;

  final Map<String, Uint8List?> imageCache = {};
  int _currentIndex;
  bool _showSelectionIndicators;
  List<MediaItem> _selectedItems;

  bool _isVideoPlaying = false;
  bool _isVideoBuffering = false;
  double _videoPosition = 0.0;
  double _videoDuration = 0.0;
  StreamSubscription<Map<String, dynamic>>? _videoEventsSubscription;
  bool _isCurrentVideo = false;
  bool _isVideoInitialized = false;
  bool _isVideoDisposing = false;
  Timer? _positionUpdateTimer;

  FullScreenMediaCubit({
    required this.mediaItems,
    required int initialIndex,
    required List<MediaItem> selectedItems,
    required this.onItemSelected,
    bool showSelectionIndicators = true,
  }) : _currentIndex = initialIndex,
       _showSelectionIndicators = showSelectionIndicators,
       _selectedItems = List.from(selectedItems),
       super(const FullScreenMediaState.initial()) {
    _checkCurrentMediaType();
    _preloadImages();
  }

  void _checkCurrentMediaType() {
    final currentItem = mediaItems[_currentIndex];
    _isCurrentVideo =
        currentItem.type == 'video' ||
        currentItem.type == MediaType.videos.name;
  }

  Future<void> _preloadImages() async {
    emit(const FullScreenMediaState.loading());

    final indices = [
      _currentIndex,
      if (_currentIndex - 1 >= 0) _currentIndex - 1,
      if (_currentIndex + 1 < mediaItems.length) _currentIndex + 1,
    ];

    for (final index in indices) {
      await _loadImage(mediaItems[index]);
    }

    emit(
      FullScreenMediaState.loaded(
        mediaItems: mediaItems,
        currentIndex: _currentIndex,
        imageCache: Map.from(imageCache),
        showSelectionIndicators: _showSelectionIndicators,
        selectedMediaItems: List.from(_selectedItems),
        isVideoPlaying: _isCurrentVideo ? _isVideoPlaying : null,
        videoPosition: _isCurrentVideo ? _videoPosition : null,
        videoDuration: _isCurrentVideo ? _videoDuration : null,
        isVideoBuffering: _isCurrentVideo ? _isVideoBuffering : null,
      ),
    );

    if (_isCurrentVideo && !_isVideoInitialized) {
      await _initializeVideo();
    }
  }

  Future<void> _loadImage(MediaItem item) async {
    if (imageCache.containsKey(item.id)) return;

    try {
      if (item.uri.startsWith('data:') || item.uri.startsWith('file://')) {
        final data = await _loadDirectData(item.uri);
        imageCache[item.id] = data;
      } else {
        final mediaType = (item.type == 'video') ? 'video' : 'image';
        final data = await _mediaLibrary.getThumbnail(
          mediaId: item.id,
          mediaType: mediaType,
          width: 1080,
          height: 1080,
        );
        imageCache[item.id] = data;
      }

      state.maybeMap(
        loaded: (s) => emit(s.copyWith(imageCache: Map.from(imageCache))),
        orElse: () {},
      );
    } catch (e) {
      await _loadDirectAsFallback(item);
    }
  }

  Future<Uint8List?> _loadDirectData(String uri) async {
    try {
      if (uri.startsWith('data:')) {
        final base64Data = uri.split(',').last;
        return base64Decode(base64Data);
      } else if (uri.startsWith('file://')) {
        final fileUri = Uri.parse(uri);

        String path = fileUri.toFilePath(windows: Platform.isWindows);

        if (Platform.isWindows && path.startsWith('/') && path.length > 1) {
          if (path[2] == ':') {
            path = path.substring(1);
          }
        }

        final file = File(path);
        return await file.readAsBytes();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _loadDirectAsFallback(MediaItem item) async {
    try {
      if (item.thumbnail != null) {
        imageCache[item.id] = item.thumbnail;
      } else if (item.uri.startsWith('http')) {
        final response = await http.get(Uri.parse(item.uri));
        if (response.statusCode == 200) {
          imageCache[item.id] = response.bodyBytes;
        }
      }

      if (imageCache.containsKey(item.id)) {
        state.maybeMap(
          loaded: (s) => emit(s.copyWith(imageCache: Map.from(imageCache))),
          orElse: () {},
        );
      }
    } catch (_) {}
  }

  Future<void> _initializeVideo() async {
    if (_isVideoDisposing || _isVideoInitialized) return;

    try {
      _isVideoInitialized = false;
      _isVideoBuffering = true;
      _videoPosition = 0.0;
      _videoDuration = 0.0;

      _updateState();

      final currentItem = mediaItems[_currentIndex];

      _videoEventsSubscription?.cancel();
      _videoEventsSubscription = null;

      _positionUpdateTimer?.cancel();
      _positionUpdateTimer = null;

      final uri = currentItem.uri;
      String videoPath = "";

      if (uri.startsWith('file://')) {
        final fileUri = Uri.parse(uri);
        String path = fileUri.toFilePath(windows: Platform.isWindows);

        if (Platform.isWindows && path.startsWith('/') && path.length > 1) {
          if (path[2] == ':') {
            path = path.substring(1);
          }
        }
        videoPath = path;
      }

      final initialized = await _mediaLibrary.initializeVideo(
        videoPath: videoPath,
        videoUri: uri.startsWith('content://') ? uri : null,
        autoPlay: false,
        volume: 1.0,
      );

      if (!initialized) {
        throw Exception('Failed to initialize video');
      }

      _videoEventsSubscription = _mediaLibrary.videoEvents.listen(
        _handleVideoEvent,
        onError: (error) {
          _isVideoBuffering = false;
          _updateState();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isVideoBuffering = false;
      _isVideoInitialized = false;
      _updateState();
    }
  }

  void _handleVideoEvent(Map<String, dynamic> event) {
    if (_isVideoDisposing) return;

    final eventType = event['event'];

    switch (eventType) {
      case 'onPrepared':
        _videoDuration = (event['duration'] ?? 0.0).toDouble();
        _isVideoInitialized = true;
        _isVideoBuffering = false;

        _startPositionUpdateTimer();

        _updateState();

        break;

      case 'onPlaybackUpdate':
        _videoPosition = (event['position'] ?? 0.0).toDouble();
        _isVideoPlaying = event['isPlaying'] ?? false;
        _updateState();
        break;

      case 'onBufferingUpdate':
        _isVideoBuffering = event['isBuffering'] ?? false;
        _updateState();
        break;

      case 'onCompleted':
        _isVideoPlaying = false;
        _videoPosition = _videoDuration;
        _updateState();
        break;

      case 'onError':
        _isVideoPlaying = false;
        _isVideoBuffering = false;
        _positionUpdateTimer?.cancel();
        _positionUpdateTimer = null;
        _updateState();
        break;

      case 'onVideoSizeChanged':
        break;
    }
  }

  void _startPositionUpdateTimer() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (_isVideoInitialized && !_isVideoDisposing && _isVideoPlaying) {
        _updateVideoPosition();
      }
    });
  }

  Future<void> _updateVideoPosition() async {
    try {
      final position = await _mediaLibrary.getCurrentPosition();
      if (position != null && position > 0) {
        _videoPosition = position;
        _updateState();
      }
    } catch (_) {}
  }

  void _updateState() {
    state.maybeMap(
      loaded: (s) => emit(
        s.copyWith(
          isVideoPlaying: _isCurrentVideo ? _isVideoPlaying : null,
          videoPosition: _isCurrentVideo ? _videoPosition : null,
          videoDuration: _isCurrentVideo ? _videoDuration : null,
          isVideoBuffering: _isCurrentVideo ? _isVideoBuffering : null,
        ),
      ),
      orElse: () {},
    );
  }

  Future<void> _disposeVideo() async {
    if (_isVideoDisposing) return;

    _isVideoDisposing = true;
    _isVideoPlaying = false;
    _isVideoBuffering = false;
    _isVideoInitialized = false;

    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = null;

    _videoEventsSubscription?.cancel();
    _videoEventsSubscription = null;

    try {
      await _mediaLibrary.disposeVideo();
    } catch (_) {}

    _isVideoDisposing = false;
  }

  Future<void> onPageChanged(int index) async {
    if (_isCurrentVideo && _isVideoInitialized) {
      await _disposeVideo();
    }

    _currentIndex = index;
    _checkCurrentMediaType();

    state.maybeMap(
      loaded: (s) => emit(
        s.copyWith(
          currentIndex: index,
          isVideoPlaying: null,
          videoPosition: null,
          videoDuration: null,
          isVideoBuffering: null,
        ),
      ),
      orElse: () {},
    );

    await _preloadImages();
  }

  void toggleSelection() {
    final current = mediaItems[_currentIndex];
    final isSelected = _selectedItems.any((e) => e.id == current.id);

    if (isSelected) {
      _selectedItems.removeWhere((e) => e.id == current.id);
    } else {
      _selectedItems.add(current);
    }

    onItemSelected(current, !isSelected);

    state.maybeMap(
      loaded: (s) =>
          emit(s.copyWith(selectedMediaItems: List.from(_selectedItems))),
      orElse: () {},
    );
  }

  Future<void> toggleVideoPlayPause() async {
    if (!_isCurrentVideo || !_isVideoInitialized || _isVideoBuffering) return;

    try {
      if (_isVideoPlaying) {
        await _mediaLibrary.pauseVideo();
        _isVideoPlaying = false;
      } else {
        await _mediaLibrary.playVideo();
        _isVideoPlaying = true;
      }
      _updateState();
    } catch (_) {}
  }

  Future<void> seekVideo(double position) async {
    if (!_isCurrentVideo || !_isVideoInitialized || _isVideoDisposing) return;

    try {
      final safePosition = position.clamp(0.0, _videoDuration);

      _videoPosition = safePosition;
      _updateState();

      await _mediaLibrary.seekVideoTo(safePosition);
    } catch (_) {}
  }

  Future<void> seekBackward() async {
    if (!_isCurrentVideo || !_isVideoInitialized) return;

    final newPosition = _videoPosition - 10;
    await seekVideo(newPosition > 0 ? newPosition : 0);
  }

  Future<void> seekForward() async {
    if (!_isCurrentVideo || !_isVideoInitialized) return;

    final newPosition = _videoPosition + 10;
    if (newPosition <= _videoDuration) {
      await seekVideo(newPosition);
    }
  }

  bool isSelected(MediaItem item) => _selectedItems.any((e) => e.id == item.id);

  int getSelectionIndex(MediaItem item) =>
      _selectedItems.indexWhere((e) => e.id == item.id) + 1;

  bool get isCurrentVideo => _isCurrentVideo;

  bool get isVideoInitialized => _isVideoInitialized;

  @override
  Future<void> close() async {
    await _disposeVideo();
    return super.close();
  }
}
