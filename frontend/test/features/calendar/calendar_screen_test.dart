import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:smart_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/entities/task_filter.dart';
import 'package:smart_todo_app/features/task/domain/repositories/task_repository.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const TaskFilter()));

  late _MockTaskRepository repository;

  Task taskDueToday() {
    final now = DateTime.now();
    return Task(
      id: 't1',
      title: 'Appuntamento',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      dueDate: DateTime(now.year, now.month, now.day, 10),
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    repository = _MockTaskRepository();
  });

  Widget wrap() => ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: CalendarScreen()),
      );

  testWidgets('shows the day tasks for the selected (today) day',
      (tester) async {
    when(() => repository.list(filter: any(named: 'filter')))
        .thenAnswer((_) async => [taskDueToday()]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Appuntamento'), findsOneWidget);
  });

  testWidgets('shows an empty message when the selected day has no tasks',
      (tester) async {
    when(() => repository.list(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar_empty')), findsOneWidget);
  });
}
