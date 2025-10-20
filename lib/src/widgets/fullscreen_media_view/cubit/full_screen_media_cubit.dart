import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:device_media_library/device_media_library.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_ui_package/src/models/media_item.dart';

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
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    emit(const FullScreenMediaState.loading());

    final indices = [
      _currentIndex,
      _currentIndex - 1,
      _currentIndex + 1,
    ].where((i) => i >= 0 && i < mediaItems.length).toList();

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
      ),
    );
  }

  Future<void> _loadImage(MediaItem item) async {
    if (imageCache.containsKey(item.id)) return;

    try {
      final data = await _mediaLibrary.getThumbnail(
        mediaId: item.id,
        mediaType: item.type,
        width: 1080,
        height: 1080,
      );
      imageCache[item.id] = data;

      state.maybeMap(
        loaded: (s) => emit(s.copyWith(imageCache: Map.from(imageCache))),
        orElse: () {},
      );
    } catch (_) {}
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(currentIndex: index)),
      orElse: () {},
    );
    _preloadImages();
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

  bool isSelected(MediaItem item) => _selectedItems.any((e) => e.id == item.id);

  int getSelectionIndex(MediaItem item) =>
      _selectedItems.indexWhere((e) => e.id == item.id) + 1;
}
