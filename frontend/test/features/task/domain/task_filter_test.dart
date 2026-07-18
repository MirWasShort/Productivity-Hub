import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/entities/task_filter.dart';

void main() {
  test('the default filter is unfiltered with createdAt desc', () {
    const filter = TaskFilter();

    expect(filter.status, isNull);
    expect(filter.priority, isNull);
    expect(filter.search, isNull);
    expect(filter.listId, isNull);
    expect(filter.sortBy, TaskSortField.createdAt);
    expect(filter.direction, SortDirection.desc);
    expect(filter.isDefault, isTrue);
  });

  test('copyWith sets and clears individual fields', () {
    const filter = TaskFilter();

    final withStatus = filter.copyWith(status: TaskStatus.todo);
    expect(withStatus.status, TaskStatus.todo);
    expect(withStatus.isDefault, isFalse);

    final cleared = withStatus.copyWith(clearStatus: true);
    expect(cleared.status, isNull);
    expect(cleared.isDefault, isTrue);
  });

  test('copyWith keeps unrelated fields', () {
    final filter = const TaskFilter()
        .copyWith(status: TaskStatus.todo)
        .copyWith(search: 'spesa');

    expect(filter.status, TaskStatus.todo);
    expect(filter.search, 'spesa');
  });

  test('equality is structural', () {
    expect(const TaskFilter().copyWith(search: 'a'),
        const TaskFilter().copyWith(search: 'a'));
    expect(const TaskFilter().copyWith(search: 'a'),
        isNot(const TaskFilter().copyWith(search: 'b')));
  });
}
