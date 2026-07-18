import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/list_repository_impl.dart';
import '../../domain/entities/todo_list.dart';
import '../../domain/repositories/list_repository.dart';

final todoListsProvider =
    AsyncNotifierProvider<TodoListsNotifier, List<TodoList>>(
        TodoListsNotifier.new);

class TodoListsNotifier extends AsyncNotifier<List<TodoList>> {
  ListRepository get _repository => ref.read(listRepositoryProvider);

  @override
  Future<List<TodoList>> build() => _repository.list();

  Future<void> createList({required String name, String? color}) async {
    final created = await _repository.create(name: name, color: color);
    state = AsyncValue.data([...state.value ?? [], created]);
  }

  Future<void> renameList({
    required String id,
    required String name,
    String? color,
  }) async {
    final updated = await _repository.update(id: id, name: name, color: color);
    state = AsyncValue.data([
      for (final l in state.value ?? <TodoList>[])
        l.id == updated.id ? updated : l,
    ]);
  }

  Future<void> deleteList(String id) async {
    await _repository.delete(id);
    state = AsyncValue.data(
        (state.value ?? <TodoList>[]).where((l) => l.id != id).toList());
  }
}
