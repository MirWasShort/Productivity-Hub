import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(TaskListNotifier.new);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() => _repository.list();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repository.list);
  }

  Future<void> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final created = await _repository.create(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
    state = AsyncValue.data([created, ...state.value ?? []]);
  }

  Future<void> updateTask(Task task) async {
    final updated = await _repository.update(task);
    state = AsyncValue.data([
      for (final t in state.value ?? <Task>[]) t.id == updated.id ? updated : t,
    ]);
  }

  /// Optimistic-lite: drop the task locally right away; if the server
  /// disagrees, reload the list so the UI shows the truth again.
  Future<void> deleteTask(String id) async {
    final previous = state.value ?? <Task>[];
    state = AsyncValue.data(previous.where((t) => t.id != id).toList());
    try {
      await _repository.delete(id);
    } catch (_) {
      await refresh();
    }
  }
}
