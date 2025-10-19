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
  final List<MediaItem> selectedItems;
  final Function(MediaItem, bool) onItemSelected;

  final Map<String, Uint8List?> imageCache = {};
  int _currentIndex;
  bool _showSelectionIndicators;

  FullScreenMediaCubit({
    required this.mediaItems,
    required int initialIndex,
    required this.selectedItems,
    required this.onItemSelected,
    bool showSelectionIndicators = true,
  }) : _currentIndex = initialIndex,
       _showSelectionIndicators = showSelectionIndicators,
       super(const FullScreenMediaState.initial()) {
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    emit(const FullScreenMediaState.loading());

    final indices = [
      _currentIndex,
      _currentIndex - 1,
      _currentIndex + 1,
    ].where((index) => index >= 0 && index < mediaItems.length).toList();

    for (final index in indices) {
      await _loadImage(mediaItems[index]);
    }

    emit(
      FullScreenMediaState.loaded(
        mediaItems: mediaItems,
        currentIndex: _currentIndex,
        imageCache: Map.from(imageCache),
        showSelectionIndicators: _showSelectionIndicators,
      ),
    );
  }

  Future<void> _loadImage(MediaItem item) async {
    if (imageCache.containsKey(item.id)) return;

    try {
      final imageData = await _mediaLibrary.getThumbnail(
        mediaId: item.id,
        mediaType: item.type,
        width: 1080,
        height: 1080,
      );

      if (imageData != null) {
        imageCache[item.id] = imageData;

        state.maybeMap(
          loaded: (state) {
            emit(state.copyWith(imageCache: Map.from(imageCache)));
          },
          orElse: () {},
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void onPageChanged(int index) {
    _currentIndex = index;

    state.maybeMap(
      loaded: (state) {
        emit(state.copyWith(currentIndex: index));
      },
      orElse: () {},
    );

    _preloadImages();
  }

  void toggleSelection() {
    final currentItem = mediaItems[_currentIndex];
    final selected = selectedItems.any(
      (selected) => selected.id == currentItem.id,
    );
    onItemSelected(currentItem, !selected);

    state.maybeMap(
      loaded: (state) {
        emit(state);
      },
      orElse: () {},
    );
  }

  void toggleSelectionIndicators() {
    _showSelectionIndicators = !_showSelectionIndicators;

    state.maybeMap(
      loaded: (state) {
        emit(state.copyWith(showSelectionIndicators: _showSelectionIndicators));
      },
      orElse: () {},
    );
  }

  bool isSelected(MediaItem item) =>
      selectedItems.any((selected) => selected.id == item.id);

  int getSelectionIndex(MediaItem item) =>
      selectedItems.indexWhere((selected) => selected.id == item.id) + 1;

  Uint8List? getImage(MediaItem item) => imageCache[item.id];

  // Геттеры для доступа к приватным полям
  int get currentIndex => _currentIndex;
  bool get showSelectionIndicators => _showSelectionIndicators;
}
