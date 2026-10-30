import 'audio_item.dart';
import 'file_item.dart';
import 'media_item.dart';
import 'media_source.dart';

class SelectedMediaItem {
  final String id;
  final String uri;
  final String name;
  final String type;
  final int size;

  final int? duration;
  final int? dateAdded;

  final MediaSource source;

  const SelectedMediaItem({
    required this.id,
    required this.uri,
    required this.name,
    required this.type,
    required this.size,
    this.duration,
    this.dateAdded,
    this.source = MediaSource.device,
  });

  factory SelectedMediaItem.fromMediaItem(
    MediaItem item, {
    MediaSource source = MediaSource.device,
  }) {
    return SelectedMediaItem(
      id: item.id,
      uri: item.uri,
      name: item.name,
      type: item.type,
      size: item.size,
      duration: item.duration,
      dateAdded: item.dateAdded,
      source: source,
    );
  }

  factory SelectedMediaItem.fromFileItem(FileItem item) {
    return SelectedMediaItem(
      id: item.id,
      uri: item.uri,
      name: item.name,
      type: item.type,
      size: item.size,
      dateAdded: item.dateAdded,
      source: item.source,
    );
  }

  factory SelectedMediaItem.fromAudioItem(AudioItem item) {
    return SelectedMediaItem(
      id: item.id,
      uri: item.uri,
      name: item.name,
      type: 'audio',
      size: item.size,
      duration: item.duration,
      dateAdded: item.dateAdded,
      source: MediaSource.device,
    );
  }

  factory SelectedMediaItem.fromMap(Map<String, dynamic> map) {
    return SelectedMediaItem(
      id: map['id']?.toString() ?? '',
      uri: map['uri']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? 'file',
      size: _parseInt(map['size']),
      duration: _parseIntOrNull(map['duration']),
      dateAdded: _parseIntOrNull(map['dateAdded']),
      source: MediaSource.fromString(map['source']?.toString()),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'uri': uri,
    'name': name,
    'type': type,
    'size': size,
    'duration': duration,
    'dateAdded': dateAdded,
    'source': source.name,
  };

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedMediaItem && other.id == id && other.uri == uri;

  @override
  int get hashCode => Object.hash(id, uri);

  @override
  String toString() => 'SelectedMediaItem($type: $name)';
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _parseIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
