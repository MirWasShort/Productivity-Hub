import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/tag/data/repositories/tag_repository_impl.dart';
import 'package:smart_todo_app/features/tag/domain/repositories/tag_repository.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/entities/task_filter.dart';
import 'package:smart_todo_app/features/task/presentation/providers/task_filter_notifier.dart';
import 'package:smart_todo_app/features/task/presentation/widgets/task_filter_bar.dart';

class _MockTagRepository extends Mock implements TagRepository {}

void main() {
  late ProviderContainer container;

  Widget wrap() {
    final tagRepository = _MockTagRepository();
    when(() => tagRepository.list()).thenAnswer((_) async => []);
    container = ProviderContainer(overrides: [
      tagRepositoryProvider.overrideWithValue(tagRepository),
    ]);
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: TaskFilterBar())),
    );
  }

  testWidgets('the search field debounces before updating the filter',
      (tester) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(find.byKey(const Key('tasks_search')), 'spesa');
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(taskFilterProvider).search, isNull);

    await tester.pump(const Duration(milliseconds: 250));
    expect(container.read(taskFilterProvider).search, 'spesa');
  });

  testWidgets('typing again resets the debounce window', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(find.byKey(const Key('tasks_search')), 'sp');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byKey(const Key('tasks_search')), 'spesa');
    await tester.pump(const Duration(milliseconds: 200));
    expect(container.read(taskFilterProvider).search, isNull);

    await tester.pump(const Duration(milliseconds: 150));
    expect(container.read(taskFilterProvider).search, 'spesa');
  });

  testWidgets('a status chip toggles the status filter', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byKey(const Key('filter_status_todo')));
    await tester.pump();
    expect(container.read(taskFilterProvider).status, TaskStatus.todo);

    await tester.tap(find.byKey(const Key('filter_status_todo')));
    await tester.pump();
    expect(container.read(taskFilterProvider).status, isNull);
  });

  testWidgets('selecting a sort option updates the filter', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byKey(const Key('tasks_sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort_due_date')));
    await tester.pumpAndSettle();

    final filter = container.read(taskFilterProvider);
    expect(filter.sortBy, TaskSortField.dueDate);
    expect(filter.direction, SortDirection.asc);
  });
}
