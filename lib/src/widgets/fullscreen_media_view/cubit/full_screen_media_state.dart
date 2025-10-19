part of 'full_screen_media_cubit.dart';

@freezed
abstract class FullScreenMediaState with _$FullScreenMediaState {
  const factory FullScreenMediaState.initial() = _Initial;
  
  const factory FullScreenMediaState.loading() = _Loading;
  
  const factory FullScreenMediaState.loaded({
    required List<MediaItem> mediaItems,
    required int currentIndex,
    required Map<String, Uint8List?> imageCache,
    required bool showSelectionIndicators,
  }) = _Loaded;
  
  const factory FullScreenMediaState.error({
    required String message,
  }) = _Error;
}