import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../repositories/note_repository.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final trashedNotes = notesState.trashedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (trashedNotes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Empty Trash',
              onPressed: () => _emptyTrash(context, ref),
            ),
        ],
      ),
      body: trashedNotes.isEmpty
          ? const EmptyState(
              icon: Icons.delete_outline_rounded,
              title: 'Trash is empty',
              subtitle: 'Deleted notes will appear here',
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(notesProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: trashedNotes.length,
                itemBuilder: (context, index) {
                  final note = trashedNotes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NoteCard(
                      note: note,
                      onTap: () => _restoreNote(context, ref, note),
                      onDelete: () => _permanentlyDelete(context, ref, note),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _restoreNote(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Note'),
        content: Text('Restore "${note.title.isEmpty ? 'Untitled' : note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notesProvider.notifier).restoreNote(note);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note restored')),
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _permanentlyDelete(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Forever'),
        content: Text(
            'Permanently delete "${note.title.isEmpty ? 'Untitled' : note.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deleted,
            ),
            onPressed: () async {
              final repo = NoteRepository.instance;
              repo.delete(note.id);
              ref.read(notesProvider.notifier).refresh();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note permanently deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _emptyTrash(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Empty Trash'),
        content: const Text('Permanently delete all trashed notes? This cannot be undone.'),
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
              ref.read(notesProvider.notifier).emptyTrash();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trash emptied')),
              );
            },
            child: const Text('Empty'),
          ),
        ],
      ),
    );
  }
}
