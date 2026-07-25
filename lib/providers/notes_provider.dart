import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';

enum NoteSortMode { date, name, lastEdited, favorite, pinned }

class NotesState {
  final List<Note> notes;
  final NoteSortMode sortMode;
  final String searchQuery;
  final String? filterFolderId;
  final String? filterTagId;

  const NotesState({
    this.notes = const [],
    this.sortMode = NoteSortMode.lastEdited,
    this.searchQuery = '',
    this.filterFolderId,
    this.filterTagId,
  });

  NotesState copyWith({
    List<Note>? notes,
    NoteSortMode? sortMode,
    String? searchQuery,
    String? filterFolderId,
    String? filterTagId,
    bool clearFolderFilter = false,
    bool clearTagFilter = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      sortMode: sortMode ?? this.sortMode,
      searchQuery: searchQuery ?? this.searchQuery,
      filterFolderId: clearFolderFilter ? null : (filterFolderId ?? this.filterFolderId),
      filterTagId: clearTagFilter ? null : (filterTagId ?? this.filterTagId),
    );
  }

  List<Note> get filteredNotes {
    var result = List<Note>.from(notes);

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.plainText.toLowerCase().contains(q))
          .toList();
    }

    if (filterFolderId != null) {
      result = result.where((n) => n.folderId == filterFolderId).toList();
    }

    if (filterTagId != null) {
      result = result.where((n) => n.tags.contains(filterTagId)).toList();
    }

    switch (sortMode) {
      case NoteSortMode.date:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortMode.name:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NoteSortMode.lastEdited:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortMode.favorite:
        result.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return b.updatedAt.compareTo(a.updatedAt);
          }
          return a.isFavorite ? -1 : 1;
        });
        break;
      case NoteSortMode.pinned:
        result.sort((a, b) {
          if (a.isPinned == b.isPinned) {
            return b.updatedAt.compareTo(a.updatedAt);
          }
          return a.isPinned ? -1 : 1;
        });
        break;
    }

    return result;
  }

  List<Note> get pinnedNotes =>
      notes.where((n) => n.isPinned && !n.isArchived && !n.isTrashed).toList();

  List<Note> get favoriteNotes =>
      notes.where((n) => n.isFavorite && !n.isArchived && !n.isTrashed).toList();

  List<Note> get recentNotes {
    final active =
        notes.where((n) => !n.isArchived && !n.isTrashed).toList();
    final sorted = List<Note>.from(active)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(10).toList();
  }

  List<Note> get activeNotes =>
      notes.where((n) => !n.isArchived && !n.isTrashed).toList();

  List<Note> get archivedNotes =>
      notes.where((n) => n.isArchived).toList();

  List<Note> get trashedNotes =>
      notes.where((n) => n.isTrashed).toList();
}

class NotesNotifier extends Notifier<NotesState> {
  @override
  NotesState build() {
    _loadNotes();
    return const NotesState();
  }

  void _loadNotes() {
    final notes = NoteRepository.instance.getAll();
    state = state.copyWith(notes: notes);
  }

  void refresh() {
    _loadNotes();
  }

  void sort(NoteSortMode mode) {
    state = state.copyWith(sortMode: mode);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void filterByFolder(String? folderId) {
    state = state.copyWith(
      filterFolderId: folderId,
      clearFolderFilter: folderId == null,
    );
  }

  void filterByTag(String? tagId) {
    state = state.copyWith(
      filterTagId: tagId,
      clearTagFilter: tagId == null,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearFolderFilter: true,
      clearTagFilter: true,
    );
  }

  Future<Note> createNote({String? folderId}) async {
    final note = await NoteRepository.instance.create(folderId: folderId);
    _loadNotes();
    return note;
  }

  Future<void> saveNote(Note note) async {
    await NoteRepository.instance.save(note);
    _loadNotes();
  }

  Future<void> trashNote(Note note) async {
    await NoteRepository.instance.trash(note);
    _loadNotes();
  }

  Future<void> restoreNote(Note note) async {
    await NoteRepository.instance.restore(note);
    _loadNotes();
  }

  Future<void> archiveNote(Note note) async {
    await NoteRepository.instance.archive(note);
    _loadNotes();
  }

  Future<void> unarchiveNote(Note note) async {
    await NoteRepository.instance.unarchive(note);
    _loadNotes();
  }

  Future<void> togglePin(Note note) async {
    await NoteRepository.instance.togglePin(note);
    _loadNotes();
  }

  Future<void> toggleFavorite(Note note) async {
    await NoteRepository.instance.toggleFavorite(note);
    _loadNotes();
  }

  Future<void> moveNoteToFolder(Note note, String? folderId) async {
    await NoteRepository.instance.moveToFolder(note, folderId);
    _loadNotes();
  }

  Future<void> addTagToNote(Note note, String tagId) async {
    await NoteRepository.instance.addTag(note, tagId);
    _loadNotes();
  }

  Future<void> removeTagFromNote(Note note, String tagId) async {
    await NoteRepository.instance.removeTag(note, tagId);
    _loadNotes();
  }

  Future<void> updateContent(
      Note note, String title, String delta, String plainText) async {
    await NoteRepository.instance.updateContent(note, title, delta, plainText);
    _loadNotes();
  }

  Future<void> emptyTrash() async {
    await NoteRepository.instance.emptyTrash();
    _loadNotes();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, NotesState>(
  NotesNotifier.new,
);
