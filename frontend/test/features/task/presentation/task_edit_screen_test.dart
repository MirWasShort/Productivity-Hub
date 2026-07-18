import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/list/data/repositories/list_repository_impl.dart';
import 'package:smart_todo_app/features/list/domain/repositories/list_repository.dart';
import 'package:smart_todo_app/features/tag/data/repositories/tag_repository_impl.dart';
import 'package:smart_todo_app/features/tag/domain/entities/tag.dart';
import 'package:smart_todo_app/features/tag/domain/repositories/tag_repository.dart';
import 'package:smart_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/repositories/task_repository.dart';
import 'package:smart_todo_app/features/task/presentation/screens/task_edit_screen.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockListRepository extends Mock implements ListRepository {}

class _MockTagRepository extends Mock implements TagRepository {}

final _existing = Task(
  id: 't1',
  title: 'Spesa',
  description: 'Latte',
  status: TaskStatus.todo,
  priority: TaskPriority.high,
  createdAt: DateTime.utc(2026, 7, 18),
  updatedAt: DateTime.utc(2026, 7, 18),
);

void main() {
  late _MockTaskRepository repository;

  setUpAll(() {
    registerFallbackValue(_existing);
    registerFallbackValue(TaskPriority.medium);
    registerFallbackValue(<String>[]);
  });

  late _MockListRepository listRepository;
  late _MockTagRepository tagRepository;

  setUp(() {
    repository = _MockTaskRepository();
    listRepository = _MockListRepository();
    tagRepository = _MockTagRepository();
    when(() => repository.list()).thenAnswer((_) async => [_existing]);
    when(() => listRepository.list()).thenAnswer((_) async => []);
    when(() => tagRepository.list()).thenAnswer((_) async => []);
  });

  Widget wrap({Task? task}) {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        listRepositoryProvider.overrideWithValue(listRepository),
        tagRepositoryProvider.overrideWithValue(tagRepository),
      ],
      child: MaterialApp(home: TaskEditScreen(task: task)),
    );
  }

  group('create mode', () {
    testWidgets('renders empty fields and the create title', (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.text('Nuovo task'), findsOneWidget);
      expect(find.byKey(const Key('task_title')), findsOneWidget);
      expect(find.byKey(const Key('task_description')), findsOneWidget);
      expect(find.byKey(const Key('task_priority')), findsOneWidget);
      expect(find.byKey(const Key('task_save')), findsOneWidget);
    });

    testWidgets('does not submit when the title is empty', (tester) async {
      await tester.pumpWidget(wrap());

      await tester.tap(find.byKey(const Key('task_save')));
      await tester.pump();

      verifyNever(() => repository.create(
            title: any(named: 'title'),
            description: any(named: 'description'),
            priority: any(named: 'priority'),
            dueDate: any(named: 'dueDate'),
            listId: any(named: 'listId'),
            tagIds: any(named: 'tagIds'),
          ));
    });

    testWidgets('creates the task with the typed values', (tester) async {
      when(() => repository.create(
            title: 'Palestra',
            description: 'Gambe',
            priority: TaskPriority.medium,
            dueDate: null,
            listId: null,
            tagIds: const <String>[],
          )).thenAnswer((_) async => _existing);

      await tester.pumpWidget(wrap());
      await tester.enterText(find.byKey(const Key('task_title')), 'Palestra');
      await tester.enterText(find.byKey(const Key('task_description')), 'Gambe');
      await tester.ensureVisible(find.byKey(const Key('task_save')));
      await tester.tap(find.byKey(const Key('task_save')));
      await tester.pumpAndSettle();

      verify(() => repository.create(
            title: 'Palestra',
            description: 'Gambe',
            priority: TaskPriority.medium,
            dueDate: null,
            listId: null,
            tagIds: const <String>[],
          )).called(1);
    });
  });

  group('tags', () {
    testWidgets('shows tag chips and sends the selected tag on create',
        (tester) async {
      when(() => tagRepository.list()).thenAnswer((_) async =>
          [const Tag(id: 'tag-1', name: 'urgente', color: '#FF0000')]);
      when(() => repository.create(
            title: any(named: 'title'),
            description: any(named: 'description'),
            priority: any(named: 'priority'),
            dueDate: any(named: 'dueDate'),
            listId: any(named: 'listId'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => _existing);

      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('task_title')), 'Con tag');

      await tester.tap(find.byKey(const Key('task_tag_tag-1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('task_save')));
      await tester.pumpAndSettle();

      final captured = verify(() => repository.create(
            title: any(named: 'title'),
            description: any(named: 'description'),
            priority: any(named: 'priority'),
            dueDate: any(named: 'dueDate'),
            listId: any(named: 'listId'),
            tagIds: captureAny(named: 'tagIds'),
          )).captured.single as List<String>;
      expect(captured, ['tag-1']);
    });
  });

  group('edit mode', () {
    testWidgets('pre-fills the fields with the existing task', (tester) async {
      await tester.pumpWidget(wrap(task: _existing));

      expect(find.text('Spesa'), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.byKey(const Key('task_status')), findsOneWidget);
    });

    testWidgets('updates the task with the modified values', (tester) async {
      when(() => repository.update(any())).thenAnswer((_) async => _existing);

      await tester.pumpWidget(wrap(task: _existing));
      await tester.enterText(find.byKey(const Key('task_title')), 'Spesa grande');
      await tester.ensureVisible(find.byKey(const Key('task_save')));
      await tester.tap(find.byKey(const Key('task_save')));
      await tester.pumpAndSettle();

      final updated = verify(() => repository.update(captureAny())).captured.single as Task;
      expect(updated.id, 't1');
      expect(updated.title, 'Spesa grande');
      expect(updated.priority, TaskPriority.high);
    });
  });
}
