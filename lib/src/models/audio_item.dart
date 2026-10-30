import 'dart:typed_data';

import 'media_item.dart';

class AudioItem {
  final String id;
  final String name;
  final String uri;
  final int dateAdded;
  final int size;

  final int duration;
  final String mimeType;
  final String artist;
  final String album;
  final String albumId;
  final String albumName;
  final int width;
  final int height;

  const AudioItem({
    required this.id,
    required this.name,
    required this.uri,
    required this.dateAdded,
    required this.size,
    required this.duration,
    required this.mimeType,
    required this.artist,
    required this.album,
    required this.albumId,
    required this.albumName,
    this.width = 0,
    this.height = 0,
  });

  factory AudioItem.fromMap(Map<String, dynamic> map) {
    return AudioItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      uri: map['uri']?.toString() ?? '',
      dateAdded: _parseInt(map['dateAdded']),
      size: _parseInt(map['size']),
      duration: _parseInt(map['duration']),
      mimeType: map['mimeType']?.toString() ?? '',
      artist: map['artist']?.toString() ?? '',
      album: map['album']?.toString() ?? '',
      albumId: map['albumId']?.toString() ?? '',
      albumName: map['albumName']?.toString() ?? '',
      width: _parseInt(map['width']),
      height: _parseInt(map['height']),
    );
  }

  MediaItem toMediaItem({Uint8List? thumbnail}) {
    return MediaItem(
      id: id,
      name: name,
      uri: uri,
      dateAdded: dateAdded,
      size: size,
      width: width,
      height: height,
      albumId: albumId,
      albumName: albumName,
      type: 'audio',
      duration: duration,
      thumbnail: thumbnail,
    );
  }

  AudioItem copyWith({
    String? id,
    String? name,
    String? uri,
    int? dateAdded,
    int? size,
    int? duration,
    String? mimeType,
    String? artist,
    String? album,
    String? albumId,
    String? albumName,
    int? width,
    int? height,
  }) {
    return AudioItem(
      id: id ?? this.id,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      dateAdded: dateAdded ?? this.dateAdded,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      mimeType: mimeType ?? this.mimeType,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  String get formattedDuration {
    if (duration <= 0) return '';
    final d = Duration(milliseconds: duration);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  String get displayArtist =>
      artist.isEmpty || artist == '<unknown>' ? '' : artist;

  String get displayAlbum => album.isEmpty || album == '<unknown>' ? '' : album;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioItem && other.id == id && other.uri == uri;

  @override
  int get hashCode => Object.hash(id, uri);

  @override
  String toString() => 'AudioItem(id: $id, name: $name, artist: $artist)';
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
