class Note {
  final String id;
  String title;
  String contentDelta;
  String plainText;
  String? folderId;
  List<String> tags;
  bool isPinned;
  bool isFavorite;
  bool isArchived;
  bool isTrashed;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Note({
    required this.id,
    this.title = '',
    this.contentDelta = '',
    this.plainText = '',
    this.folderId,
    this.tags = const [],
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.isTrashed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contentDelta': contentDelta,
      'plainText': plainText,
      'folderId': folderId,
      'tags': tags,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isTrashed': isTrashed,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      contentDelta: (map['contentDelta'] as String?) ?? '',
      plainText: (map['plainText'] as String?) ?? '',
      folderId: map['folderId'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPinned: (map['isPinned'] as bool?) ?? false,
      isFavorite: (map['isFavorite'] as bool?) ?? false,
      isArchived: (map['isArchived'] as bool?) ?? false,
      isTrashed: (map['isTrashed'] as bool?) ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] as int)
          : null,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? contentDelta,
    String? plainText,
    String? folderId,
    List<String>? tags,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isTrashed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentDelta: contentDelta ?? this.contentDelta,
      plainText: plainText ?? this.plainText,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isTrashed: isTrashed ?? this.isTrashed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
