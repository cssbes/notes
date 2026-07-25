class NoteFolder {
  final String id;
  String name;
  String? parentId;
  int color;
  String icon;
  DateTime createdAt;

  NoteFolder({
    required this.id,
    this.name = '',
    this.parentId,
    this.color = 0xFF007AFF,
    this.icon = 'folder',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NoteFolder.fromMap(Map<String, dynamic> map) {
    return NoteFolder(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      parentId: map['parentId'] as String?,
      color: (map['color'] as int?) ?? 0xFF007AFF,
      icon: (map['icon'] as String?) ?? 'folder',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  NoteFolder copyWith({
    String? id,
    String? name,
    String? parentId,
    int? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return NoteFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
