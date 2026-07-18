import 'task.dart';

enum TaskSortField { createdAt, dueDate, priority, title }

enum SortDirection { asc, desc }

/// Active search criteria for the task list. Immutable; null means
/// "no filter on this dimension". `clear*` flags exist because copyWith
/// cannot distinguish "not passed" from "set to null".
final class TaskFilter {
  const TaskFilter({
    this.status,
    this.priority,
    this.search,
    this.listId,
    this.sortBy = TaskSortField.createdAt,
    this.direction = SortDirection.desc,
  });

  final TaskStatus? status;
  final TaskPriority? priority;
  final String? search;
  final String? listId;
  final TaskSortField sortBy;
  final SortDirection direction;

  bool get isDefault =>
      status == null &&
      priority == null &&
      search == null &&
      listId == null &&
      sortBy == TaskSortField.createdAt &&
      direction == SortDirection.desc;

  TaskFilter copyWith({
    TaskStatus? status,
    bool clearStatus = false,
    TaskPriority? priority,
    bool clearPriority = false,
    String? search,
    bool clearSearch = false,
    String? listId,
    bool clearListId = false,
    TaskSortField? sortBy,
    SortDirection? direction,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      search: clearSearch ? null : (search ?? this.search),
      listId: clearListId ? null : (listId ?? this.listId),
      sortBy: sortBy ?? this.sortBy,
      direction: direction ?? this.direction,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TaskFilter &&
      other.status == status &&
      other.priority == priority &&
      other.search == search &&
      other.listId == listId &&
      other.sortBy == sortBy &&
      other.direction == direction;

  @override
  int get hashCode =>
      Object.hash(status, priority, search, listId, sortBy, direction);
}
