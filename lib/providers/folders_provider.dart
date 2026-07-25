import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../repositories/folder_repository.dart';
import '../repositories/note_repository.dart';

class FoldersState {
  final List<NoteFolder> folders;
  final List<Note> notes;

  const FoldersState({
    this.folders = const [],
    this.notes = const [],
  });

  FoldersState copyWith({List<NoteFolder>? folders, List<Note>? notes}) {
    return FoldersState(
      folders: folders ?? this.folders,
      notes: notes ?? this.notes,
    );
  }

  List<NoteFolder> get rootFolders =>
      folders.where((f) => f.parentId == null).toList();

  List<NoteFolder> getSubFolders(String parentId) =>
      folders.where((f) => f.parentId == parentId).toList();

  int noteCount(String folderId) =>
      notes.where((n) => n.folderId == folderId && !n.isTrashed).length;
}

class FoldersNotifier extends Notifier<FoldersState> {
  @override
  FoldersState build() {
    _load();
    return const FoldersState();
  }

  void _load() {
    state = FoldersState(
      folders: FolderRepository.instance.getAll(),
      notes: NoteRepository.instance.getAll(),
    );
  }

  void refresh() => _load();

  Future<NoteFolder> create(String name, {String? parentId, int? color}) async {
    final folder =
        await FolderRepository.instance.create(name, parentId: parentId, color: color);
    _load();
    return folder;
  }

  Future<void> rename(String id, String name) async {
    await FolderRepository.instance.rename(id, name);
    _load();
  }

  Future<void> delete(String id) async {
    await FolderRepository.instance.delete(id);
    _load();
  }

  Future<void> update(NoteFolder folder) async {
    await FolderRepository.instance.save(folder);
    _load();
  }
}

final foldersProvider = NotifierProvider<FoldersNotifier, FoldersState>(
  FoldersNotifier.new,
);
