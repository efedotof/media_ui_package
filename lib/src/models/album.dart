class Album {
  final String id;
  final String name;
  final String coverPath;
  final String type;

  Album({
    required this.id,
    required this.name,
    required this.coverPath,
    required this.type,
  });

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      coverPath: map['coverPath']?.toString() ?? '',
      type: map['type']?.toString() ?? 'mixed',
    );
  }
}
