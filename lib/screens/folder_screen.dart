import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../providers/folders_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/folder_tile.dart';


class FolderScreen extends ConsumerStatefulWidget {
  final String folderId;
  final String? title;

  const FolderScreen({
    super.key,
    required this.folderId,
    this.title,
  });

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  NoteFolder? _getFolder() {
    final folders = ref.read(foldersProvider).folders;
    return folders.where((f) => f.id == widget.folderId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folder = _getFolder();
    final notesState = ref.watch(notesProvider);
    final subFolders = ref.watch(foldersProvider).getSubFolders(widget.folderId);

    final notesInFolder = notesState.activeNotes
        .where((n) => n.folderId == widget.folderId)
        .toList();

    final filteredNotes = notesState.searchQuery.isNotEmpty
        ? notesInFolder
            .where((n) =>
                n.title
                    .toLowerCase()
                    .contains(notesState.searchQuery.toLowerCase()) ||
                n.plainText
                    .toLowerCase()
                    .contains(notesState.searchQuery.toLowerCase()))
            .toList()
        : notesInFolder;

    return Scaffold(
      appBar: AppBar(
        title: Text(folder?.name ?? widget.title ?? 'Folder'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNote(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          AppSearchBar(
            controller: _searchController,
            onChanged: (query) {
              ref.read(notesProvider.notifier).search(query);
            },
            showClear: notesState.searchQuery.isNotEmpty,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(notesProvider.notifier).refresh();
                ref.read(foldersProvider.notifier).refresh();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                children: [
                  if (subFolders.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 8),
                      child: Text(
                        'Subfolders',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    ...subFolders.map((sf) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FolderTile(
                            folder: sf,
                            noteCount: ref
                                .watch(foldersProvider)
                                .noteCount(sf.id),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FolderScreen(folderId: sf.id),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 12),
                  ],
                  if (filteredNotes.isEmpty && subFolders.isEmpty)
                    const EmptyState(
                      icon: Icons.note_outlined,
                      title: 'No notes in this folder',
                      subtitle: 'Tap + to create a note here',
                    )
                  else if (filteredNotes.isEmpty && notesState.searchQuery.isNotEmpty)
                    const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results',
                    )
                  else
                    ...filteredNotes.map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NoteCard(
                            note: note,
                            onTap: () => _openNote(note),
                            onPin: () => ref
                                .read(notesProvider.notifier)
                                .togglePin(note),
                            onFavorite: () => ref
                                .read(notesProvider.notifier)
                                .toggleFavorite(note),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createNote() async {
    // Note editor coming soon
  }

  void _openNote(Note note) {
    // Note editor coming soon
  }
}
