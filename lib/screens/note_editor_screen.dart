import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/folders_provider.dart';
import '../providers/tags_provider.dart';
import '../widgets/tag_chip.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteEditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late QuillController _quillController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  Timer? _autoSaveTimer;
  bool _isInitialized = false;
  Note? _note;
  String _title = '';
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _quillController = QuillController.basic();
    _loadNote();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNote() {
    final notes = ref.read(notesProvider);
    final note = notes.notes.where((n) => n.id == widget.noteId).firstOrNull;
    if (note == null) return;

    _note = note;
    _title = note.title;

    if (note.contentDelta.isNotEmpty) {
      try {
        final deltaJson = jsonDecode(note.contentDelta);
        final document = Document.fromJson(deltaJson as List<dynamic>);
        _quillController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _quillController = QuillController.basic();
      }
    } else {
      _quillController = QuillController.basic();
    }

    _quillController.addListener(_onContentChanged);
    _isInitialized = true;
    setState(() {});
  }

  void _onContentChanged() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(
      const Duration(milliseconds: AppConstants.autoSaveDelayMs),
      _save,
    );
  }

  Future<void> _save() async {
    if (_note == null || !_isInitialized) return;

    final delta = _quillController.document.toDelta().toJson();
    final deltaJson = jsonEncode(delta);
    final plainText = _quillController.document.toPlainText().trim();

    String title = _title.trim();
    if (title.isEmpty) {
      final lines = plainText.split('\n');
      title = lines.firstWhere((l) => l.isNotEmpty, orElse: () => '').trim();
      if (title.length > 100) title = title.substring(0, 100);
    }

    await ref.read(notesProvider.notifier).updateContent(
          _note!,
          title,
          deltaJson,
          plainText,
        );
  }

  Future<void> _saveAndExit() async {
    _autoSaveTimer?.cancel();
    await _save();
    if (mounted) Navigator.pop(context);
  }

  int get _wordCount {
    final text = _quillController.document.toPlainText().trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _charCount {
    return _quillController.document.toPlainText().trim().length;
  }

  int get _readingTime {
    final wc = _wordCount;
    return (wc / 200).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isDark),
            Expanded(
              child: GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: _buildEditor(isDark),
              ),
            ),
            _buildToolbar(isDark),
            if (_showStats) _buildStatsBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
            ),
            onPressed: _saveAndExit,
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: _title,
                  selection: TextSelection.collapsed(offset: _title.length),
                ),
              ),
              onChanged: (val) => _title = val,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          _EditorActionButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _showNoteOptions(isDark),
          ),
          _EditorActionButton(
            icon: _showStats ? Icons.info_rounded : Icons.info_outline_rounded,
            onTap: () => setState(() => _showStats = !_showStats),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppConstants.editorBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuillEditor.basic(
                controller: _quillController,
                focusNode: _focusNode,
                scrollController: _scrollController,
                config: QuillEditorConfig(
                  placeholder: 'Start writing...',
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  autoFocus: false,
                  expands: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('bold'),
              onTap: () => _quillController.formatSelection(
                  Attribute.bold),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('italic'),
              onTap: () => _quillController.formatSelection(
                  Attribute.italic),
            ),
            _ToolbarButton(
              icon: Icons.format_underline,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('underline'),
              onTap: () => _quillController.formatSelection(
                  Attribute.underline),
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.title,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('heading'),
              onTap: _toggleHeading,
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('list') &&
                  _quillController.getSelectionStyle().attributes['list']!.value == 'bullet',
              onTap: () => _quillController.formatSelection(
                  const ListAttribute('bullet')),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('list') &&
                  _quillController.getSelectionStyle().attributes['list']!.value == 'ordered',
              onTap: () => _quillController.formatSelection(
                  const ListAttribute('ordered')),
            ),
            _ToolbarButton(
              icon: Icons.checklist_rounded,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('list') &&
                  _quillController.getSelectionStyle().attributes['list']!.value == 'check',
              onTap: () => _quillController.formatSelection(
                  const ListAttribute('check')),
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.format_quote,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('blockQuote'),
              onTap: () => _quillController.formatSelection(
                  Attribute.blockQuote),
            ),
            _ToolbarButton(
              icon: Icons.code_rounded,
              isActive: _quillController.getSelectionStyle().attributes.containsKey('codeBlock'),
              onTap: () => _quillController.formatSelection(
                  Attribute.codeBlock),
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.link_rounded,
              isActive: false,
              onTap: _insertLink,
            ),
            _ToolbarButton(
              icon: Icons.horizontal_rule_rounded,
              isActive: false,
              onTap: _insertHorizontalRule,
            ),
            _ToolbarButton(
              icon: Icons.emoji_emotions_outlined,
              isActive: false,
              onTap: _insertDate,
            ),
            _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.undo_rounded,
              isActive: false,
              onTap: () => _quillController.undo(),
            ),
            _ToolbarButton(
              icon: Icons.redo_rounded,
              isActive: false,
              onTap: () => _quillController.redo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _StatItem(label: 'Words', value: '$_wordCount', isDark: isDark),
          const SizedBox(width: 24),
          _StatItem(label: 'Chars', value: '$_charCount', isDark: isDark),
          const SizedBox(width: 24),
          _StatItem(label: 'Read', value: '$_readingTime min', isDark: isDark),
        ],
      ),
    );
  }

  void _toggleHeading() {
    final current = _quillController.getSelectionStyle().attributes['heading'];
    if (current != null) {
      _quillController.formatSelection(Attribute.clone(Attribute.h1, null));
    } else {
      _quillController.formatSelection(Attribute.h1);
    }
  }

  void _insertLink() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Insert Link'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _quillController.formatSelection(
                    LinkAttribute(controller.text));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _insertHorizontalRule() {
    final index = _quillController.selection.baseOffset;
    if (index >= 0) {
      _quillController.document.insert(index, const BlockEmbed('hr', ''));
    }
  }

  void _insertDate() {
    final now = DateTime.now();
    final formatted = DateFormat('MMM d, yyyy').format(now);
    final index = _quillController.selection.baseOffset;
    if (index < 0) return;
    _quillController.document.insert(index, formatted);
  }

  void _showNoteOptions(bool isDark) {
    final note = _note;
    if (note == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              _OptionItem(
                icon: note.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                title: note.isPinned ? 'Unpin' : 'Pin',
                onTap: () {
                  ref.read(notesProvider.notifier).togglePin(note);
                  Navigator.pop(ctx);
                },
              ),
              _OptionItem(
                icon: note.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                title: note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                onTap: () {
                  ref.read(notesProvider.notifier).toggleFavorite(note);
                  Navigator.pop(ctx);
                },
              ),
              _OptionItem(
                icon: Icons.folder_outlined,
                title: 'Move to Folder',
                onTap: () {
                  Navigator.pop(ctx);
                  _showFolderPicker(isDark);
                },
              ),
              _OptionItem(
                icon: Icons.label_outline,
                title: 'Manage Tags',
                onTap: () {
                  Navigator.pop(ctx);
                  _showTagManager(isDark);
                },
              ),
              _OptionItem(
                icon: Icons.archive_outlined,
                title: 'Archive',
                onTap: () {
                  ref.read(notesProvider.notifier).archiveNote(note);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
              _OptionItem(
                icon: Icons.delete_outline_rounded,
                title: 'Move to Trash',
                titleColor: AppColors.deleted,
                onTap: () {
                  ref.read(notesProvider.notifier).trashNote(note);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderPicker(bool isDark) {
    final folders = ref.read(foldersProvider).folders;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Move to Folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('No folder'),
                onTap: () {
                  ref
                      .read(notesProvider.notifier)
                      .moveNoteToFolder(_note!, null);
                  Navigator.pop(ctx);
                },
              ),
              ...folders.map((folder) => ListTile(
                    leading: Icon(Icons.folder_rounded, color: Color(folder.color)),
                    title: Text(folder.name),
                    onTap: () {
                      ref
                          .read(notesProvider.notifier)
                          .moveNoteToFolder(_note!, folder.id);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagManager(bool isDark) {
    final tagsState = ref.read(tagsProvider);
    final note = _note!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Manage Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              if (note.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note.tags.map((tagId) {
                      final tag = tagsState.tags.where((t) => t.id == tagId).firstOrNull;
                      if (tag == null) return const SizedBox();
                      return TagChip(
                        tag: tag,
                        onDelete: () {
                          ref
                              .read(notesProvider.notifier)
                              .removeTagFromNote(note, tagId);
                        },
                      );
                    }).toList(),
                  ),
                ),
              if (tagsState.tags.isNotEmpty)
                ...tagsState.tags
                    .where((t) => !note.tags.contains(t.id))
                    .map((tag) => ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(tag.color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.label_rounded,
                                color: Color(tag.color), size: 18),
                          ),
                          title: Text(tag.name),
                          onTap: () {
                            ref
                                .read(notesProvider.notifier)
                                .addTagToNote(note, tag.id);
                          },
                        ))
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No tags yet. Create tags in the Tags tab.')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive
            ? AppColors.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppColors.accent
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}

class _EditorActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _EditorActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
          ),
        ),
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  const _OptionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = titleColor ??
        (isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21));

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
