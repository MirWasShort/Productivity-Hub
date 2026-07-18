import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';

final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => const TaskFilter();

  /// Tapping the active status chip clears it (single-select toggle).
  void toggleStatus(TaskStatus status) {
    state = state.status == status
        ? state.copyWith(clearStatus: true)
        : state.copyWith(status: status);
  }

  void togglePriority(TaskPriority priority) {
    state = state.priority == priority
        ? state.copyWith(clearPriority: true)
        : state.copyWith(priority: priority);
  }

  void setSearch(String term) {
    final trimmed = term.trim();
    state = trimmed.isEmpty
        ? state.copyWith(clearSearch: true)
        : state.copyWith(search: trimmed);
  }

  void setSort(TaskSortField sortBy, SortDirection direction) {
    state = state.copyWith(sortBy: sortBy, direction: direction);
  }

  void setListId(String? listId) {
    state = listId == null
        ? state.copyWith(clearListId: true)
        : state.copyWith(listId: listId);
  }

  void toggleTag(String tagId) {
    state = state.tagId == tagId
        ? state.copyWith(clearTagId: true)
        : state.copyWith(tagId: tagId);
  }

  void clear() => state = const TaskFilter();
}
