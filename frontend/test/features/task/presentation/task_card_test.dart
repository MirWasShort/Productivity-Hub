import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/core/theme/app_theme.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/presentation/widgets/task_card.dart';

Task _task({
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.high,
  DateTime? dueDate,
}) =>
    Task(
      id: 't1',
      title: 'Spesa settimanale',
      description: 'Latte e pane',
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.utc(2026, 7, 18),
      updatedAt: DateTime.utc(2026, 7, 18),
    );

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('renders title, description and priority label', (tester) async {
    await tester.pumpWidget(_wrap(TaskCard(task: _task())));

    expect(find.text('Spesa settimanale'), findsOneWidget);
    expect(find.text('Latte e pane'), findsOneWidget);
    expect(find.text('ALTA'), findsOneWidget);
  });

  testWidgets('shows the due date when present', (tester) async {
    await tester.pumpWidget(
        _wrap(TaskCard(task: _task(dueDate: DateTime(2026, 8, 1)))));

    expect(find.byIcon(Icons.event_outlined), findsOneWidget);
    expect(find.textContaining('1/8/2026'), findsOneWidget);
  });

  testWidgets('hides the due date row when absent', (tester) async {
    await tester.pumpWidget(_wrap(TaskCard(task: _task())));

    expect(find.byIcon(Icons.event_outlined), findsNothing);
  });

  testWidgets('a DONE task shows strikethrough title', (tester) async {
    await tester.pumpWidget(
        _wrap(TaskCard(task: _task(status: TaskStatus.done))));

    final title = tester.widget<Text>(find.text('Spesa settimanale'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
  });
}
