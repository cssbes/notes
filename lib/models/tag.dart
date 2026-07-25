class NoteTag {
  final String id;
  String name;
  int color;
  DateTime createdAt;

  NoteTag({
    required this.id,
    this.name = '',
    this.color = 0xFF007AFF,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NoteTag.fromMap(Map<String, dynamic> map) {
    return NoteTag(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      color: (map['color'] as int?) ?? 0xFF007AFF,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  NoteTag copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
  }) {
    return NoteTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
