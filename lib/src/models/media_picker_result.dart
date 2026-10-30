import 'selected_media_item.dart';

class MediaPickerResult {
  final List<SelectedMediaItem> items;
  final bool canceled;

  const MediaPickerResult({required this.items, this.canceled = false});

  factory MediaPickerResult.canceled() =>
      const MediaPickerResult(items: [], canceled: true);

  factory MediaPickerResult.single(SelectedMediaItem item) =>
      MediaPickerResult(items: [item]);

  factory MediaPickerResult.fromItems(List<SelectedMediaItem> items) =>
      MediaPickerResult(items: List.unmodifiable(items));

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get count => items.length;

  List<String> get uris => items.map((e) => e.uri).toList(growable: false);

  List<String> get ids => items.map((e) => e.id).toList(growable: false);

  int get totalSize => items.fold(0, (sum, item) => sum + item.size);

  @override
  String toString() => 'MediaPickerResult(count: $count, canceled: $canceled)';
}
