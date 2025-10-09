import 'dart:typed_data';

class MediaItem {
  final String id;
  final String name;
  final String path;
  final int dateAdded;
  final int size;
  final int width;
  final int height;
  final String albumId;
  final String albumName;
  final String type;
  final int? duration;
  final Uint8List? thumbnail;

  MediaItem({
    required this.id,
    required this.name,
    required this.path,
    required this.dateAdded,
    required this.size,
    required this.width,
    required this.height,
    required this.albumId,
    required this.albumName,
    required this.type,
    this.duration,
    this.thumbnail,
  });

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      path: map['path']?.toString() ?? '',
      dateAdded: _parseInt(map['dateAdded']),
      size: _parseInt(map['size']),
      width: _parseInt(map['width']),
      height: _parseInt(map['height']),
      albumId: map['albumId']?.toString() ?? '',
      albumName: map['albumName']?.toString() ?? '',
      type: map['type']?.toString() ?? 'image',
      duration: _parseInt(map['duration']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  MediaItem copyWith({
    Uint8List? thumbnail,
  }) {
    return MediaItem(
      id: id,
      name: name,
      path: path,
      dateAdded: dateAdded,
      size: size,
      width: width,
      height: height,
      albumId: albumId,
      albumName: albumName,
      type: type,
      duration: duration,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
