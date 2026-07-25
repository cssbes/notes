import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/folder.dart';

class FolderTile extends StatelessWidget {
  final NoteFolder folder;
  final int noteCount;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const FolderTile({
    super.key,
    required this.folder,
    required this.noteCount,
    required this.onTap,
    this.onRename,
    this.onDelete,
  });

  IconData _getIcon() {
    switch (folder.icon) {
      case 'folder':
        return Icons.folder_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'photo':
        return Icons.photo_rounded;
      case 'code':
        return Icons.code_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(folder.color);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(), color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFE4E6EB)
                            : const Color(0xFF1C1E21),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$noteCount notes',
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
              PopupMenuBuilder(
                onRename: onRename,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PopupMenuBuilder extends StatelessWidget {
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const PopupMenuBuilder({super.key, this.onRename, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: Colors.grey.shade500,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      onSelected: (value) {
        switch (value) {
          case 'rename':
            onRename?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18),
              SizedBox(width: 10),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }
}
