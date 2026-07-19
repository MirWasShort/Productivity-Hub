import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calendar/presentation/providers/calendar_notifier.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_filter_notifier.dart';

final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(TaskListNotifier.new);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() {
    // Watching the filter makes Riverpod re-run build whenever it
    // changes: the list reloads itself, no manual wiring.
    final filter = ref.watch(taskFilterProvider);
    return _repository.list(filter: filter);
  }

  Future<void> refresh() async {
    final filter = ref.read(taskFilterProvider);
    state = await AsyncValue.guard(() => _repository.list(filter: filter));
  }

  Future<void> createTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? listId,
    List<String> tagIds = const [],
  }) async {
    final created = await _repository.create(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      listId: listId,
      tagIds: tagIds,
    );
    state = AsyncValue.data([created, ...state.value ?? []]);
    _invalidateCalendar();
  }

  Future<void> updateTask(Task task) async {
    final updated = await _repository.update(task);
    state = AsyncValue.data([
      for (final t in state.value ?? <Task>[]) t.id == updated.id ? updated : t,
    ]);
    _invalidateCalendar();
  }

  /// Optimistic-lite: drop the task locally right away; if the server
  /// disagrees, reload the list so the UI shows the truth again.
  Future<void> deleteTask(String id) async {
    final previous = state.value ?? <Task>[];
    state = AsyncValue.data(previous.where((t) => t.id != id).toList());
    try {
      await _repository.delete(id);
      _invalidateCalendar();
    } catch (_) {
      await refresh();
    }
  }

  // The calendar keeps its own filter-independent fetch of the same
  // server data, so every successful mutation here must invalidate it
  // or it goes stale until the next full reload.
  void _invalidateCalendar() => ref.invalidate(calendarTasksProvider);
}
