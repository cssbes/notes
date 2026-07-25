import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';

class TagsState {
  final List<NoteTag> tags;
  final Map<String, int> noteCounts;

  const TagsState({
    this.tags = const [],
    this.noteCounts = const {},
  });

  TagsState copyWith({List<NoteTag>? tags, Map<String, int>? noteCounts}) {
    return TagsState(
      tags: tags ?? this.tags,
      noteCounts: noteCounts ?? this.noteCounts,
    );
  }

  int count(String tagId) => noteCounts[tagId] ?? 0;
}

class TagsNotifier extends Notifier<TagsState> {
  @override
  TagsState build() {
    _load();
    return const TagsState();
  }

  void _load() {
    final tags = TagRepository.instance.getAll();
    final counts = <String, int>{};
    for (final tag in tags) {
      counts[tag.id] = TagRepository.instance.getNoteCount(tag.id);
    }
    state = TagsState(tags: tags, noteCounts: counts);
  }

  void refresh() => _load();

  Future<NoteTag> create(String name, {int? color}) async {
    final tag = await TagRepository.instance.create(name, color: color);
    _load();
    return tag;
  }

  Future<void> delete(String id) async {
    await TagRepository.instance.delete(id);
    _load();
  }

  Future<void> update(NoteTag tag) async {
    await TagRepository.instance.save(tag);
    _load();
  }
}

final tagsProvider = NotifierProvider<TagsNotifier, TagsState>(
  TagsNotifier.new,
);
