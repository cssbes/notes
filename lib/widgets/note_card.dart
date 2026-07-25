import 'package:flutter/material.dart';
import '../core/extensions.dart';
import '../core/theme/app_colors.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onPin;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onPin,
    this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: note.isPinned
              ? Border.all(color: AppColors.pinned.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFE4E6EB)
                          : const Color(0xFF1C1E21),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.push_pin_rounded,
                      size: 16,
                      color: AppColors.pinned,
                    ),
                  ),
                if (note.isFavorite)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.favorite,
                    ),
                  ),
              ],
            ),
            if (note.plainText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                note.plainText,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFB0B3B8)
                      : const Color(0xFF65676B),
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  note.updatedAt.formatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                if (onFavorite != null)
                  _ActionButton(
                    icon: note.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: note.isFavorite ? AppColors.favorite : null,
                    onTap: onFavorite!,
                  ),
                if (onPin != null)
                  _ActionButton(
                    icon: note.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: note.isPinned ? AppColors.pinned : null,
                    onTap: onPin!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 18,
            color: color ?? Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
