import 'package:flutter/foundation.dart';
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
  bool _hasError = false;
  String? _errorMessage;

  bool get isInitialized => _initialized;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('[DB] Starting database initialization...');

    try {
      debugPrint('[DB] Initializing Hive...');
      await Hive.initFlutter();
      debugPrint('[DB] Hive initialized.');

      debugPrint('[DB] Opening boxes...');
      await Future.wait([
        Hive.openBox(AppConstants.notesBox),
        Hive.openBox(AppConstants.foldersBox),
        Hive.openBox(AppConstants.tagsBox),
        Hive.openBox(AppConstants.settingsBox),
      ]);
      debugPrint('[DB] All boxes opened.');

      _initialized = true;
      debugPrint('[DB] Database initialization complete.');
    } catch (e, stack) {
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('[DB] Database initialization FAILED: $e');
      debugPrint('[DB] Stack trace: $stack');
    }
  }

  Box? _getBox(String name) {
    try {
      return Hive.box(name);
    } catch (e) {
      debugPrint('[DB] Failed to access box "$name": $e');
      return null;
    }
  }

  Box? get _notesBox => _getBox(AppConstants.notesBox);
  Box? get _foldersBox => _getBox(AppConstants.foldersBox);
  Box? get _tagsBox => _getBox(AppConstants.tagsBox);
  Box? get _settingsBox => _getBox(AppConstants.settingsBox);

  List<Note> getAllNotes() {
    final box = _notesBox;
    if (box == null) return [];
    try {
      return box.values
          .map((e) => Note.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[DB] Failed to read notes: $e');
      return [];
    }
  }

  Note? getNote(String id) {
    final box = _notesBox;
    if (box == null) return null;
    try {
      final data = box.get(id);
      if (data == null) return null;
      return Note.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('[DB] Failed to get note $id: $e');
      return null;
    }
  }

  Future<void> saveNote(Note note) async {
    final box = _notesBox;
    if (box == null) return;
    try {
      await box.put(note.id, note.toMap());
    } catch (e) {
      debugPrint('[DB] Failed to save note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    final box = _notesBox;
    if (box == null) return;
    try {
      await box.delete(id);
    } catch (e) {
      debugPrint('[DB] Failed to delete note: $e');
    }
  }

  Future<void> deleteAllNotes() async {
    final box = _notesBox;
    if (box == null) return;
    try {
      await box.clear();
    } catch (e) {
      debugPrint('[DB] Failed to clear notes: $e');
    }
  }

  List<NoteFolder> getAllFolders() {
    final box = _foldersBox;
    if (box == null) return [];
    try {
      return box.values
          .map((e) =>
              NoteFolder.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[DB] Failed to read folders: $e');
      return [];
    }
  }

  NoteFolder? getFolder(String id) {
    final box = _foldersBox;
    if (box == null) return null;
    try {
      final data = box.get(id);
      if (data == null) return null;
      return NoteFolder.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('[DB] Failed to get folder $id: $e');
      return null;
    }
  }

  Future<void> saveFolder(NoteFolder folder) async {
    final box = _foldersBox;
    if (box == null) return;
    try {
      await box.put(folder.id, folder.toMap());
    } catch (e) {
      debugPrint('[DB] Failed to save folder: $e');
    }
  }

  Future<void> deleteFolder(String id) async {
    final box = _foldersBox;
    if (box == null) return;
    try {
      await box.delete(id);
    } catch (e) {
      debugPrint('[DB] Failed to delete folder: $e');
    }
  }

  List<NoteTag> getAllTags() {
    final box = _tagsBox;
    if (box == null) return [];
    try {
      return box.values
          .map((e) => NoteTag.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[DB] Failed to read tags: $e');
      return [];
    }
  }

  NoteTag? getTag(String id) {
    final box = _tagsBox;
    if (box == null) return null;
    try {
      final data = box.get(id);
      if (data == null) return null;
      return NoteTag.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('[DB] Failed to get tag $id: $e');
      return null;
    }
  }

  Future<void> saveTag(NoteTag tag) async {
    final box = _tagsBox;
    if (box == null) return;
    try {
      await box.put(tag.id, tag.toMap());
    } catch (e) {
      debugPrint('[DB] Failed to save tag: $e');
    }
  }

  Future<void> deleteTag(String id) async {
    final box = _tagsBox;
    if (box == null) return;
    try {
      await box.delete(id);
    } catch (e) {
      debugPrint('[DB] Failed to delete tag: $e');
    }
  }

  AppSettings getSettings() {
    final box = _settingsBox;
    if (box == null) return AppSettings.defaults();
    try {
      final data = box.get(AppConstants.settingsKey);
      if (data == null) return AppSettings.defaults();
      return AppSettings.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('[DB] Failed to read settings: $e');
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = _settingsBox;
    if (box == null) return;
    try {
      await box.put(AppConstants.settingsKey, settings.toMap());
    } catch (e) {
      debugPrint('[DB] Failed to save settings: $e');
    }
  }

  Future<void> importBackup(Map<String, dynamic> backup) async {
    if (backup.containsKey('notes')) {
      final notes = backup['notes'] as List;
      final box = _notesBox;
      if (box != null) {
        for (final noteData in notes) {
          try {
            final note =
                Note.fromMap(Map<String, dynamic>.from(noteData as Map));
            await box.put(note.id, note.toMap());
          } catch (e) {
            debugPrint('[DB] Failed to import note: $e');
          }
        }
      }
    }
    if (backup.containsKey('folders')) {
      final folders = backup['folders'] as List;
      final box = _foldersBox;
      if (box != null) {
        for (final folderData in folders) {
          try {
            final folder =
                NoteFolder.fromMap(Map<String, dynamic>.from(folderData as Map));
            await box.put(folder.id, folder.toMap());
          } catch (e) {
            debugPrint('[DB] Failed to import folder: $e');
          }
        }
      }
    }
    if (backup.containsKey('tags')) {
      final tags = backup['tags'] as List;
      final box = _tagsBox;
      if (box != null) {
        for (final tagData in tags) {
          try {
            final tag =
                NoteTag.fromMap(Map<String, dynamic>.from(tagData as Map));
            await box.put(tag.id, tag.toMap());
          } catch (e) {
            debugPrint('[DB] Failed to import tag: $e');
          }
        }
      }
    }
  }

  Map<String, dynamic> exportBackup() {
    final notes = _notesBox?.values
            .map((e) =>
                Note.fromMap(Map<String, dynamic>.from(e as Map)).toMap())
            .toList() ??
        [];
    final folders = _foldersBox?.values
            .map((e) =>
                NoteFolder.fromMap(Map<String, dynamic>.from(e as Map)).toMap())
            .toList() ??
        [];
    final tags = _tagsBox?.values
            .map((e) => NoteTag.fromMap(Map<String, dynamic>.from(e as Map)).toMap())
            .toList() ??
        [];
    return {
      'version': 1,
      'exportedAt': DateTime.now().millisecondsSinceEpoch,
      'notes': notes,
      'folders': folders,
      'tags': tags,
    };
  }
}
