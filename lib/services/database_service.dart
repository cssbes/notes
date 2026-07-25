import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../models/tag.dart';
import '../models/app_settings.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(AppConstants.notesBox),
      Hive.openBox(AppConstants.foldersBox),
      Hive.openBox(AppConstants.tagsBox),
      Hive.openBox(AppConstants.settingsBox),
    ]);

    _initialized = true;
  }

  Box get _notesBox => Hive.box(AppConstants.notesBox);
  Box get _foldersBox => Hive.box(AppConstants.foldersBox);
  Box get _tagsBox => Hive.box(AppConstants.tagsBox);
  Box get _settingsBox => Hive.box(AppConstants.settingsBox);

  List<Note> getAllNotes() {
    return _notesBox.values
        .map((e) => Note.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Note? getNote(String id) {
    final data = _notesBox.get(id);
    if (data == null) return null;
    return Note.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note.toMap());
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<void> deleteAllNotes() async {
    await _notesBox.clear();
  }

  List<NoteFolder> getAllFolders() {
    return _foldersBox.values
        .map((e) =>
            NoteFolder.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  NoteFolder? getFolder(String id) {
    final data = _foldersBox.get(id);
    if (data == null) return null;
    return NoteFolder.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveFolder(NoteFolder folder) async {
    await _foldersBox.put(folder.id, folder.toMap());
  }

  Future<void> deleteFolder(String id) async {
    await _foldersBox.delete(id);
  }

  List<NoteTag> getAllTags() {
    return _tagsBox.values
        .map((e) => NoteTag.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  NoteTag? getTag(String id) {
    final data = _tagsBox.get(id);
    if (data == null) return null;
    return NoteTag.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveTag(NoteTag tag) async {
    await _tagsBox.put(tag.id, tag.toMap());
  }

  Future<void> deleteTag(String id) async {
    await _tagsBox.delete(id);
  }

  AppSettings getSettings() {
    final data = _settingsBox.get(AppConstants.settingsKey);
    if (data == null) return AppSettings.defaults();
    return AppSettings.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(AppConstants.settingsKey, settings.toMap());
  }

  Future<void> importBackup(Map<String, dynamic> backup) async {
    if (backup.containsKey('notes')) {
      final notes = backup['notes'] as List;
      for (final noteData in notes) {
        final note = Note.fromMap(Map<String, dynamic>.from(noteData as Map));
        await _notesBox.put(note.id, note.toMap());
      }
    }
    if (backup.containsKey('folders')) {
      final folders = backup['folders'] as List;
      for (final folderData in folders) {
        final folder =
            NoteFolder.fromMap(Map<String, dynamic>.from(folderData as Map));
        await _foldersBox.put(folder.id, folder.toMap());
      }
    }
    if (backup.containsKey('tags')) {
      final tags = backup['tags'] as List;
      for (final tagData in tags) {
        final tag =
            NoteTag.fromMap(Map<String, dynamic>.from(tagData as Map));
        await _tagsBox.put(tag.id, tag.toMap());
      }
    }
  }

  Map<String, dynamic> exportBackup() {
    return {
      'version': 1,
      'exportedAt': DateTime.now().millisecondsSinceEpoch,
      'notes': _notesBox.values
          .map((e) => Note.fromMap(Map<String, dynamic>.from(e as Map)).toMap())
          .toList(),
      'folders': _foldersBox.values
          .map((e) =>
              NoteFolder.fromMap(Map<String, dynamic>.from(e as Map)).toMap())
          .toList(),
      'tags': _tagsBox.values
          .map((e) => NoteTag.fromMap(Map<String, dynamic>.from(e as Map)).toMap())
          .toList(),
    };
  }
}
