import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/extensions.dart';
import '../core/theme/app_colors.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../providers/notes_provider.dart';
import '../providers/folders_provider.dart';
import '../providers/tags_provider.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/folder_tile.dart';
import 'note_editor_screen.dart';
import 'folder_screen.dart';
import 'settings_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: Column(
        children: [
          if (_currentTab == 0) _buildHeader(isDark),
          Expanded(child: _buildBody(isDark)),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: _createNote,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) {
          setState(() => _currentTab = index);
          if (index == 1 || index == 2) {
            ref.read(foldersProvider.notifier).refresh();
            ref.read(tagsProvider.notifier).refresh();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note_rounded),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Folders',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline),
            selectedIcon: Icon(Icons.label_rounded),
            label: 'Tags',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
            ),
          ),
          Row(
            children: [
              _HeaderIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => Navigator.push(
                  context,
                  _routeBuilder(const TrashScreen()),
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                onTap: () => Navigator.push(
                  context,
                  _routeBuilder(const SettingsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return Column(
      children: [
        if (_currentTab == 0) ...[
          AppSearchBar(
            controller: _searchController,
            onChanged: (query) {
              ref.read(notesProvider.notifier).search(query);
            },
            showClear: ref.watch(notesProvider).searchQuery.isNotEmpty,
          ),
          const SizedBox(height: 4),
        ],
        Expanded(child: _buildTabContent(isDark)),
      ],
    );
  }

  Widget _buildTabContent(bool isDark) {
    switch (_currentTab) {
      case 0:
        return _buildNotesTab(isDark);
      case 1:
        return _buildFoldersTab(isDark);
      case 2:
        return _buildTagsTab(isDark);
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildNotesTab(bool isDark) {
    final notesState = ref.watch(notesProvider);
    final filtered = notesState.filteredNotes;

    if (filtered.isEmpty && notesState.searchQuery.isEmpty) {
      return _buildOverview(isDark);
    }

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try a different search term',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(notesProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: filtered.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} note${filtered.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  _SortButton(
                    currentMode: notesState.sortMode,
                    onChanged: (mode) {
                      ref.read(notesProvider.notifier).sort(mode);
                    },
                  ),
                ],
              ),
            );
          }

          final note = filtered[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NoteCard(
              note: note,
              onTap: () => _openNote(note),
              onPin: () =>
                  ref.read(notesProvider.notifier).togglePin(note),
              onFavorite: () =>
                  ref.read(notesProvider.notifier).toggleFavorite(note),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverview(bool isDark) {
    final notesState = ref.watch(notesProvider);
    final pinned = notesState.pinnedNotes;
    final favorites = notesState.favoriteNotes;
    final recent = notesState.recentNotes;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(notesProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          if (pinned.isNotEmpty) ...[
            _SectionHeader(title: 'Pinned', isDark: isDark),
            const SizedBox(height: 8),
            ...pinned.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoteCard(
                    note: note,
                    onTap: () => _openNote(note),
                    onPin: () =>
                        ref.read(notesProvider.notifier).togglePin(note),
                    onFavorite: () =>
                        ref.read(notesProvider.notifier).toggleFavorite(note),
                  ),
                )),
            const SizedBox(height: 8),
          ],
          if (favorites.isNotEmpty) ...[
            _SectionHeader(title: 'Favorites', isDark: isDark),
            const SizedBox(height: 8),
            ...favorites.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoteCard(
                    note: note,
                    onTap: () => _openNote(note),
                    onPin: () =>
                        ref.read(notesProvider.notifier).togglePin(note),
                    onFavorite: () =>
                        ref.read(notesProvider.notifier).toggleFavorite(note),
                  ),
                )),
            const SizedBox(height: 8),
          ],
          _SectionHeader(title: 'Recent', isDark: isDark),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            const EmptyState(
              icon: Icons.note_outlined,
              title: 'No notes yet',
              subtitle: 'Tap + to create your first note',
            )
          else
            ...recent.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoteCard(
                    note: note,
                    onTap: () => _openNote(note),
                    onPin: () =>
                        ref.read(notesProvider.notifier).togglePin(note),
                    onFavorite: () =>
                        ref.read(notesProvider.notifier).toggleFavorite(note),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildFoldersTab(bool isDark) {
    final foldersState = ref.watch(foldersProvider);
    final folders = foldersState.rootFolders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateFolderDialog(isDark),
        child: const Icon(Icons.create_new_folder_rounded),
      ),
      body: folders.isEmpty
          ? const EmptyState(
              icon: Icons.folder_outlined,
              title: 'No folders',
              subtitle: 'Create folders to organize your notes',
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(foldersProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FolderTile(
                      folder: folder,
                      noteCount: foldersState.noteCount(folder.id),
                      onTap: () => Navigator.push(
                        context,
                        _routeBuilder(FolderScreen(folderId: folder.id)),
                      ),
                      onRename: () =>
                          _showRenameFolderDialog(folder, isDark),
                      onDelete: () => _deleteFolder(folder),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTagsTab(bool isDark) {
    final tagsState = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTagDialog(isDark),
        child: const Icon(Icons.add_rounded),
      ),
      body: tagsState.tags.isEmpty
          ? const EmptyState(
              icon: Icons.label_outline,
              title: 'No tags',
              subtitle: 'Create tags to categorize your notes',
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(tagsProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: tagsState.tags.length,
                itemBuilder: (context, index) {
                  final tag = tagsState.tags[index];
                  final color = Color(tag.color);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        ref
                            .read(notesProvider.notifier)
                            .filterByTag(tag.id);
                        setState(() => _currentTab = 0);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.label_rounded,
                                  color: color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tag.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFE4E6EB)
                                          : const Color(0xFF1C1E21),
                                    ),
                                  ),
                                  Text(
                                    '${tagsState.count(tag.id)} notes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_horiz_rounded,
                                  color: Colors.grey.shade500, size: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              elevation: 2,
                              onSelected: (value) {
                                if (value == 'delete') {
                                  ref
                                      .read(tagsProvider.notifier)
                                      .delete(tag.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 18),
                                      SizedBox(width: 10),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _createNote() async {
    final note = await ref.read(notesProvider.notifier).createNote();
    if (mounted) {
      Navigator.push(context, _routeBuilder(NoteEditorScreen(noteId: note.id)));
    }
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      _routeBuilder(NoteEditorScreen(noteId: note.id)),
    );
  }

  void _showCreateFolderDialog(bool isDark) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(foldersProvider.notifier)
                    .create(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameFolderDialog(NoteFolder folder, bool isDark) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(foldersProvider.notifier)
                    .rename(folder.id, controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _deleteFolder(NoteFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Folder'),
        content: Text(
            'Delete "${folder.name}"? Notes in this folder will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deleted,
            ),
            onPressed: () {
              ref.read(foldersProvider.notifier).delete(folder.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateTagDialog(bool isDark) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tag name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(tagsProvider.notifier)
                    .create(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Route _routeBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.25, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: isDark
              ? const Color(0xFFE4E6EB)
              : const Color(0xFF1C1E21)),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final NoteSortMode currentMode;
  final ValueChanged<NoteSortMode> onChanged;

  const _SortButton({required this.currentMode, required this.onChanged});

  String _modeLabel(NoteSortMode mode) {
    switch (mode) {
      case NoteSortMode.date:
        return 'Date created';
      case NoteSortMode.name:
        return 'Name';
      case NoteSortMode.lastEdited:
        return 'Last edited';
      case NoteSortMode.favorite:
        return 'Favorites';
      case NoteSortMode.pinned:
        return 'Pinned';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<NoteSortMode>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              _modeLabel(currentMode),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => NoteSortMode.values.map((mode) {
        return PopupMenuItem(
          value: mode,
          child: Row(
            children: [
              if (mode == currentMode)
                Icon(Icons.check, size: 18, color: AppColors.accent)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(_modeLabel(mode)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
