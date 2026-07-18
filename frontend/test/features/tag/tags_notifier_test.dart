import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/tag/data/repositories/tag_repository_impl.dart';
import 'package:smart_todo_app/features/tag/domain/entities/tag.dart';
import 'package:smart_todo_app/features/tag/domain/repositories/tag_repository.dart';
import 'package:smart_todo_app/features/tag/presentation/providers/tags_notifier.dart';

class _MockTagRepository extends Mock implements TagRepository {}

const _tag = Tag(id: 't1', name: 'urgente', color: '#FF0000');

void main() {
  late _MockTagRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockTagRepository();
    container = ProviderContainer(overrides: [
      tagRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  test('build loads the tags', () async {
    when(() => repository.list()).thenAnswer((_) async => [_tag]);

    expect((await container.read(tagsProvider.future)).single.name, 'urgente');
  });

  test('createTag adds the created tag', () async {
    when(() => repository.list()).thenAnswer((_) async => []);
    when(() => repository.create(name: 'casa', color: null))
        .thenAnswer((_) async => _tag);
    await container.read(tagsProvider.future);

    await container.read(tagsProvider.notifier).createTag(name: 'casa');

    expect(container.read(tagsProvider).value, contains(_tag));
  });

  test('deleteTag removes the tag', () async {
    when(() => repository.list()).thenAnswer((_) async => [_tag]);
    when(() => repository.delete('t1')).thenAnswer((_) async {});
    await container.read(tagsProvider.future);

    await container.read(tagsProvider.notifier).deleteTag('t1');

    expect(container.read(tagsProvider).value, isEmpty);
  });
}
