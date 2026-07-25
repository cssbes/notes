import 'package:uuid/uuid.dart';
import '../models/tag.dart';
import '../services/database_service.dart';

class TagRepository {
  static final TagRepository instance = TagRepository._();
  TagRepository._();

  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<NoteTag> getAll() => _db.getAllTags();

  NoteTag? get(String id) => _db.getTag(id);

  int getNoteCount(String tagId) {
    return _db.getAllNotes().where((n) => n.tags.contains(tagId)).length;
  }

  Future<NoteTag> create(String name, {int? color}) async {
    final tag = NoteTag(
      id: _uuid.v4(),
      name: name,
      color: color ?? 0xFF007AFF,
    );
    await _db.saveTag(tag);
    return tag;
  }

  Future<void> save(NoteTag tag) async {
    await _db.saveTag(tag);
  }

  Future<void> delete(String id) async {
    await _db.deleteTag(id);
    for (final note in _db.getAllNotes()) {
      if (note.tags.contains(id)) {
        final tags = note.tags.where((t) => t != id).toList();
        await _db.saveNote(note.copyWith(tags: tags));
      }
    }
  }
}
