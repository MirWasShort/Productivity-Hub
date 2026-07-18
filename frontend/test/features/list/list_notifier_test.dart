import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/list/data/repositories/list_repository_impl.dart';
import 'package:smart_todo_app/features/list/domain/entities/todo_list.dart';
import 'package:smart_todo_app/features/list/domain/repositories/list_repository.dart';
import 'package:smart_todo_app/features/list/presentation/providers/todo_lists_notifier.dart';

class _MockListRepository extends Mock implements ListRepository {}

const _list = TodoList(id: 'l1', name: 'Lavoro', color: '#4F46E5', position: 0);

void main() {
  late _MockListRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockListRepository();
    container = ProviderContainer(overrides: [
      listRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  test('build loads the lists', () async {
    when(() => repository.list()).thenAnswer((_) async => [_list]);

    final lists = await container.read(todoListsProvider.future);

    expect(lists.single.name, 'Lavoro');
  });

  test('createList adds the created list to the state', () async {
    when(() => repository.list()).thenAnswer((_) async => []);
    when(() => repository.create(name: 'Casa', color: null))
        .thenAnswer((_) async => _list);
    await container.read(todoListsProvider.future);

    await container.read(todoListsProvider.notifier).createList(name: 'Casa');

    expect(container.read(todoListsProvider).value, contains(_list));
  });

  test('deleteList removes the list', () async {
    when(() => repository.list()).thenAnswer((_) async => [_list]);
    when(() => repository.delete('l1')).thenAnswer((_) async {});
    await container.read(todoListsProvider.future);

    await container.read(todoListsProvider.notifier).deleteList('l1');

    expect(container.read(todoListsProvider).value, isEmpty);
  });
}
