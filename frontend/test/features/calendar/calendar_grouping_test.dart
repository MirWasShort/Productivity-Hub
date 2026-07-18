import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/features/calendar/domain/calendar_grouping.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';

Task _task(String id, {DateTime? due}) => Task(
      id: id,
      title: id,
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      dueDate: due,
      createdAt: DateTime.utc(2026, 7, 1),
      updatedAt: DateTime.utc(2026, 7, 1),
    );

void main() {
  test('buckets tasks by their local due day, ignoring the time', () {
    final map = groupTasksByDay([
      _task('a', due: DateTime(2026, 7, 18, 9)),
      _task('b', due: DateTime(2026, 7, 18, 23, 30)),
      _task('c', due: DateTime(2026, 7, 20, 12)),
    ]);

    expect(map[DateTime(2026, 7, 18)]!.map((t) => t.id), ['a', 'b']);
    expect(map[DateTime(2026, 7, 20)]!.single.id, 'c');
  });

  test('tasks without a due date are excluded', () {
    final map = groupTasksByDay([_task('a'), _task('b', due: DateTime(2026, 7, 18))]);

    expect(map.values.expand((e) => e).map((t) => t.id), ['b']);
  });

  test('tasksOn returns the tasks for a given day', () {
    final tasks = [
      _task('a', due: DateTime(2026, 7, 18, 9)),
      _task('c', due: DateTime(2026, 7, 20)),
    ];

    expect(tasksOn(tasks, DateTime(2026, 7, 18, 15)).single.id, 'a');
    expect(tasksOn(tasks, DateTime(2026, 7, 19)), isEmpty);
  });
}
