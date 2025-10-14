import 'dart:typed_data';

class MediaItem {
  final String id;
  final String name;
  final String uri; // Only use URI, no path
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
    required this.uri, // Changed from path to uri
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
      uri: map['uri']?.toString() ?? '',
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
}
