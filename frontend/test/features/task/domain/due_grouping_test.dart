import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/services/due_grouping.dart';

Task _task(String id, {DateTime? due, TaskStatus status = TaskStatus.todo}) =>
    Task(
      id: id,
      title: id,
      status: status,
      priority: TaskPriority.medium,
      dueDate: due,
      createdAt: DateTime.utc(2026, 7, 1),
      updatedAt: DateTime.utc(2026, 7, 1),
    );

void main() {
  // Saturday 2026-07-18 at 15:00 local time.
  final now = DateTime(2026, 7, 18, 15);

  List<DueSection> group(List<Task> tasks) => groupByDue(tasks, now);

  test('a past-due open task is overdue', () {
    final sections = group([_task('a', due: DateTime(2026, 7, 17, 23, 59))]);

    expect(sections.single.group, DueGroup.overdue);
  });

  test('a task due later today is Oggi, even at 23:59', () {
    final sections = group([_task('a', due: DateTime(2026, 7, 18, 23, 59))]);

    expect(sections.single.group, DueGroup.today);
  });

  test('a task due earlier today but past the hour is overdue', () {
    final sections = group([_task('a', due: DateTime(2026, 7, 18, 9))]);

    expect(sections.single.group, DueGroup.overdue);
  });

  test('tomorrow is Domani', () {
    final sections = group([_task('a', due: DateTime(2026, 7, 19, 8))]);

    expect(sections.single.group, DueGroup.tomorrow);
  });

  test('within the next six days is Questa settimana', () {
    final sections = group([_task('a', due: DateTime(2026, 7, 24))]);

    expect(sections.single.group, DueGroup.thisWeek);
  });

  test('beyond a week is Più avanti', () {
    final sections = group([_task('a', due: DateTime(2026, 7, 25))]);

    expect(sections.single.group, DueGroup.later);
  });

  test('no due date is Senza scadenza', () {
    final sections = group([_task('a')]);

    expect(sections.single.group, DueGroup.noDate);
  });

  test('a DONE task is never overdue: all done tasks group under Completati',
      () {
    final sections = group([
      _task('past-done', due: DateTime(2026, 7, 10), status: TaskStatus.done),
      _task('today-done', due: DateTime(2026, 7, 18, 23), status: TaskStatus.done),
    ]);

    expect(sections.single.group, DueGroup.completed);
    expect(sections.single.tasks, hasLength(2));
  });

  test('sections come out in fixed order with empty groups omitted', () {
    final sections = group([
      _task('later', due: DateTime(2026, 9, 1)),
      _task('overdue', due: DateTime(2026, 7, 1)),
      _task('none'),
      _task('done', status: TaskStatus.done),
      _task('today', due: DateTime(2026, 7, 18, 20)),
    ]);

    expect(sections.map((s) => s.group), [
      DueGroup.overdue,
      DueGroup.today,
      DueGroup.later,
      DueGroup.noDate,
      DueGroup.completed,
    ]);
  });

  test('isOverdue matches the grouping rule', () {
    expect(isOverdue(_task('a', due: DateTime(2026, 7, 17)), now), isTrue);
    expect(
        isOverdue(_task('a', due: DateTime(2026, 7, 17), status: TaskStatus.done), now),
        isFalse);
    expect(isOverdue(_task('a', due: DateTime(2026, 7, 19)), now), isFalse);
    expect(isOverdue(_task('a'), now), isFalse);
  });
}
