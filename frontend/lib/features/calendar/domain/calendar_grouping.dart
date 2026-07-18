import '../../task/domain/entities/task.dart';

DateTime _localDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Groups tasks by their local due day (midnight-keyed). Tasks without a
/// due date are excluded — they don't belong on a calendar.
Map<DateTime, List<Task>> groupTasksByDay(List<Task> tasks) {
  final map = <DateTime, List<Task>>{};
  for (final task in tasks) {
    if (task.dueDate == null) {
      continue;
    }
    map.putIfAbsent(_localDay(task.dueDate!), () => []).add(task);
  }
  return map;
}

/// Tasks due on the same local day as [day].
List<Task> tasksOn(List<Task> tasks, DateTime day) {
  final target = _localDay(day);
  return tasks
      .where((t) => t.dueDate != null && _localDay(t.dueDate!) == target)
      .toList();
}
