import '../entities/task.dart';
import '../entities/task_filter.dart';

/// Boundary of the task feature. Implementations may throw [Failure]s.
abstract interface class TaskRepository {
  Future<List<Task>> list({TaskFilter filter = const TaskFilter()});

  Future<Task> getById(String id);

  Future<Task> create({
    required String title,
    String? description,
    TaskPriority priority,
    DateTime? dueDate,
  });

  Future<Task> update(Task task);

  Future<void> delete(String id);
}
