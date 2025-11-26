part of 'media_grid_cubit.dart';

@freezed
abstract class MediaGridState with _$MediaGridState {
  const factory MediaGridState.initial() = _Initial;
  const factory MediaGridState.loading() = _Loading;
  const factory MediaGridState.permissionRequesting() = _PermissionRequesting;
  const factory MediaGridState.permissionDenied() = _PermissionDenied;
  const factory MediaGridState.loaded({
    required List<MediaItem> mediaItems,
    required Map<String, Uint8List?> thumbnailCache,
    required bool hasMoreItems,
    required int currentOffset,
    required bool isLoadingMore,
    required bool showSelectionIndicators,
    required List<MediaItem> selectedMediaItems,
  }) = _Loaded;
  const factory MediaGridState.error({required String message}) = _Error;
}
