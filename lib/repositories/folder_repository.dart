import 'package:uuid/uuid.dart';
import '../models/folder.dart';
import '../services/database_service.dart';

class FolderRepository {
  static final FolderRepository instance = FolderRepository._();
  FolderRepository._();

  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<NoteFolder> getAll() => _db.getAllFolders();

  List<NoteFolder> getRootFolders() =>
      _db.getAllFolders().where((f) => f.parentId == null).toList();

  List<NoteFolder> getSubFolders(String parentId) =>
      _db.getAllFolders().where((f) => f.parentId == parentId).toList();

  NoteFolder? get(String id) => _db.getFolder(id);

  Future<NoteFolder> create(String name, {String? parentId, int? color}) async {
    final folder = NoteFolder(
      id: _uuid.v4(),
      name: name,
      parentId: parentId,
      color: color ?? 0xFF007AFF,
    );
    await _db.saveFolder(folder);
    return folder;
  }

  Future<void> save(NoteFolder folder) async {
    await _db.saveFolder(folder);
  }

  Future<void> delete(String id) async {
    await _db.deleteFolder(id);
  }

  Future<void> rename(String id, String name) async {
    final folder = _db.getFolder(id);
    if (folder != null) {
      await _db.saveFolder(folder.copyWith(name: name));
    }
  }
}
