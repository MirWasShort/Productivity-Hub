import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tag_repository_impl.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

final tagsProvider =
    AsyncNotifierProvider<TagsNotifier, List<Tag>>(TagsNotifier.new);

class TagsNotifier extends AsyncNotifier<List<Tag>> {
  TagRepository get _repository => ref.read(tagRepositoryProvider);

  @override
  Future<List<Tag>> build() => _repository.list();

  Future<void> createTag({required String name, String? color}) async {
    final created = await _repository.create(name: name, color: color);
    state = AsyncValue.data([...state.value ?? [], created]);
  }

  Future<void> deleteTag(String id) async {
    await _repository.delete(id);
    state = AsyncValue.data(
        (state.value ?? <Tag>[]).where((t) => t.id != id).toList());
  }
}
