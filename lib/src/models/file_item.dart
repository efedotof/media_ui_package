import 'media_source.dart';

class FileItem {
  final String id;
  final String name;
  final String uri;

  final String path;
  final int dateAdded;
  final int size;

  final String mimeType;

  final String type;

  final String category;
  final int width;
  final int height;
  final String albumName;

  final MediaSource source;

  const FileItem({
    required this.id,
    required this.name,
    required this.uri,
    required this.path,
    required this.dateAdded,
    required this.size,
    required this.mimeType,
    required this.type,
    required this.category,
    required this.width,
    required this.height,
    required this.albumName,
    this.source = MediaSource.downloads,
  });

  factory FileItem.fromMap(
    Map<String, dynamic> map, {
    MediaSource source = MediaSource.downloads,
  }) {
    return FileItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      uri: map['uri']?.toString() ?? '',
      path: map['path']?.toString() ?? '',
      dateAdded: _parseInt(map['dateAdded']),
      size: _parseInt(map['size']),
      mimeType: map['mimeType']?.toString() ?? '',
      type: map['type']?.toString() ?? 'file',
      category:
          map['category']?.toString() ??
          (source == MediaSource.documents ? 'document' : 'download'),
      width: _parseInt(map['width']),
      height: _parseInt(map['height']),
      albumName: map['albumName']?.toString() ?? '',
      source: source,
    );
  }

  factory FileItem.fromDownload(Map<String, dynamic> map) =>
      FileItem.fromMap(map, source: MediaSource.downloads);

  factory FileItem.fromDocument(Map<String, dynamic> map) =>
      FileItem.fromMap(map, source: MediaSource.documents);

  FileItem copyWith({
    String? id,
    String? name,
    String? uri,
    String? path,
    int? dateAdded,
    int? size,
    String? mimeType,
    String? type,
    String? category,
    int? width,
    int? height,
    String? albumName,
    MediaSource? source,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      path: path ?? this.path,
      dateAdded: dateAdded ?? this.dateAdded,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      category: category ?? this.category,
      width: width ?? this.width,
      height: height ?? this.height,
      albumName: albumName ?? this.albumName,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'uri': uri,
    'path': path,
    'dateAdded': dateAdded,
    'size': size,
    'mimeType': mimeType,
    'type': type,
    'category': category,
    'width': width,
    'height': height,
    'albumName': albumName,
  };

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isGenericFile => type == 'file';

  bool get hasRealPath => path.isNotEmpty || uri.startsWith('file://');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileItem && other.id == id && other.uri == uri;

  @override
  int get hashCode => Object.hash(id, uri);

  @override
  String toString() => 'FileItem(id: $id, name: $name, type: $type)';
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
