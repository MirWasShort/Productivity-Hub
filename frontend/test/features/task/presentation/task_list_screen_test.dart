import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/entities/task_filter.dart';
import 'package:smart_todo_app/features/task/domain/repositories/task_repository.dart';
import 'package:smart_todo_app/features/task/presentation/screens/task_list_screen.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

Task _task(String id, String title, {TaskPriority priority = TaskPriority.medium}) =>
    Task(
      id: id,
      title: title,
      status: TaskStatus.todo,
      priority: priority,
      createdAt: DateTime.utc(2026, 7, 18),
      updatedAt: DateTime.utc(2026, 7, 18),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const TaskFilter());
  });

  late _MockTaskRepository repository;

  setUp(() {
    repository = _MockTaskRepository();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [taskRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: TaskListScreen()),
    );
  }

  testWidgets('renders the tasks returned by the repository', (tester) async {
    when(() => repository.list()).thenAnswer(
        (_) async => [_task('t1', 'Spesa', priority: TaskPriority.high), _task('t2', 'Palestra')]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Spesa'), findsOneWidget);
    expect(find.text('Palestra'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no tasks', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => []);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tasks_empty')), findsOneWidget);
  });

  testWidgets('shows the error state with a retry button on failure', (tester) async {
    when(() => repository.list()).thenThrow(Exception('boom'));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tasks_retry')), findsOneWidget);
  });

  testWidgets('groups tasks in due sections with count badges', (tester) async {
    final now = DateTime.now();
    when(() => repository.list(filter: any(named: 'filter'))).thenAnswer((_) async => [
          Task(
            id: 'late',
            title: 'In ritardo!',
            status: TaskStatus.todo,
            priority: TaskPriority.high,
            dueDate: now.subtract(const Duration(days: 2)),
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: 'nodate',
            title: 'Senza data',
            status: TaskStatus.todo,
            priority: TaskPriority.low,
            createdAt: now,
            updatedAt: now,
          ),
        ]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('In ritardo'), findsOneWidget);
    expect(find.text('Senza scadenza'), findsOneWidget);
    expect(find.byKey(const Key('due_section_overdue')), findsOneWidget);
    expect(find.byKey(const Key('due_section_noDate')), findsOneWidget);
  });

  testWidgets('quick-add sheet creates a task with the typed title', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => []);
    when(() => repository.create(
          title: 'Nuovo task',
          description: null,
          priority: TaskPriority.medium,
          dueDate: null,
        )).thenAnswer((_) async => _task('t9', 'Nuovo task'));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tasks_fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('quick_add_title')), 'Nuovo task');
    await tester.tap(find.byKey(const Key('quick_add_submit')));
    await tester.pumpAndSettle();

    verify(() => repository.create(
          title: 'Nuovo task',
          description: null,
          priority: TaskPriority.medium,
          dueDate: null,
        )).called(1);
  });
}
