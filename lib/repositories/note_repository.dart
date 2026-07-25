import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NoteRepository {
  static final NoteRepository instance = NoteRepository._();
  NoteRepository._();

  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<Note> getAll() => _db.getAllNotes();

  List<Note> getActive() =>
      _db.getAllNotes().where((n) => !n.isArchived && !n.isTrashed).toList();

  List<Note> getArchived() =>
      _db.getAllNotes().where((n) => n.isArchived).toList();

  List<Note> getTrashed() =>
      _db.getAllNotes().where((n) => n.isTrashed).toList();

  List<Note> getFavorites() =>
      getActive().where((n) => n.isFavorite).toList();

  List<Note> getPinned() => getActive().where((n) => n.isPinned).toList();

  List<Note> getRecent() {
    final notes = getActive();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes.take(10).toList();
  }

  List<Note> getByFolder(String folderId) =>
      getActive().where((n) => n.folderId == folderId).toList();

  List<Note> getByTag(String tag) =>
      getActive().where((n) => n.tags.contains(tag)).toList();

  List<Note> search(String query) {
    final q = query.toLowerCase();
    return getActive()
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.plainText.toLowerCase().contains(q))
        .toList();
  }

  List<Note> searchInFolder(String query, String folderId) {
    return getByFolder(folderId).where((n) {
      final q = query.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.plainText.toLowerCase().contains(q);
    }).toList();
  }

  List<Note> searchByTag(String query, String tagId) {
    return getByTag(tagId).where((n) {
      final q = query.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.plainText.toLowerCase().contains(q);
    }).toList();
  }

  Note? get(String id) => _db.getNote(id);

  Future<Note> create({String? folderId}) async {
    final note = Note(
      id: _uuid.v4(),
      folderId: folderId,
    );
    await _db.saveNote(note);
    return note;
  }

  Future<void> save(Note note) async {
    await _db.saveNote(note.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String id) async {
    await _db.deleteNote(id);
  }

  Future<void> trash(Note note) async {
    await _db.saveNote(note.copyWith(
      isTrashed: true,
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> restore(Note note) async {
    await _db.saveNote(note.copyWith(
      isTrashed: false,
      deletedAt: null,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> archive(Note note) async {
    await _db.saveNote(note.copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> unarchive(Note note) async {
    await _db.saveNote(note.copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> togglePin(Note note) async {
    await _db.saveNote(note.copyWith(
      isPinned: !note.isPinned,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> toggleFavorite(Note note) async {
    await _db.saveNote(note.copyWith(
      isFavorite: !note.isFavorite,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> moveToFolder(Note note, String? folderId) async {
    await _db.saveNote(note.copyWith(
      folderId: folderId,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> addTag(Note note, String tagId) async {
    final tags = [...note.tags];
    if (!tags.contains(tagId)) {
      tags.add(tagId);
      await _db.saveNote(note.copyWith(tags: tags, updatedAt: DateTime.now()));
    }
  }

  Future<void> removeTag(Note note, String tagId) async {
    final tags = note.tags.where((t) => t != tagId).toList();
    await _db.saveNote(note.copyWith(tags: tags, updatedAt: DateTime.now()));
  }

  Future<void> updateContent(Note note, String title, String contentDelta,
      String plainText) async {
    await _db.saveNote(note.copyWith(
      title: title,
      contentDelta: contentDelta,
      plainText: plainText,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> emptyTrash() async {
    final trashed = getTrashed();
    for (final note in trashed) {
      await _db.deleteNote(note.id);
    }
  }
}
