import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/error/failures.dart';
import 'package:smart_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/repositories/task_repository.dart';
import 'package:smart_todo_app/features/task/presentation/providers/task_list_notifier.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

Task _task(String id, String title) => Task(
      id: id,
      title: title,
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      createdAt: DateTime.utc(2026, 7, 18),
      updatedAt: DateTime.utc(2026, 7, 18),
    );

void main() {
  late _MockTaskRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockTaskRepository();
    container = ProviderContainer(overrides: [
      taskRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  test('build loads the task list from the repository', () async {
    when(() => repository.list())
        .thenAnswer((_) async => [_task('t1', 'Spesa'), _task('t2', 'Palestra')]);

    final tasks = await container.read(taskListProvider.future);

    expect(tasks.map((t) => t.title), ['Spesa', 'Palestra']);
  });

  test('build surfaces the failure as an error state', () async {
    when(() => repository.list())
        .thenAnswer((_) async => throw const NetworkFailure());

    container.listen(taskListProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    final state = container.read(taskListProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<NetworkFailure>());
  });

  test('createTask adds the created task to the state', () async {
    when(() => repository.list()).thenAnswer((_) async => [_task('t1', 'Spesa')]);
    when(() => repository.create(
          title: 'Nuovo',
          description: null,
          priority: TaskPriority.medium,
          dueDate: null,
          listId: null,
          tagIds: const <String>[],
        )).thenAnswer((_) async => _task('t9', 'Nuovo'));
    await container.read(taskListProvider.future);

    await container.read(taskListProvider.notifier).createTask(title: 'Nuovo');

    final titles =
        container.read(taskListProvider).value!.map((t) => t.title).toList();
    expect(titles, contains('Nuovo'));
  });

  test('deleteTask removes the task and calls the API', () async {
    when(() => repository.list())
        .thenAnswer((_) async => [_task('t1', 'Spesa'), _task('t2', 'Palestra')]);
    when(() => repository.delete('t1')).thenAnswer((_) async {});
    await container.read(taskListProvider.future);

    await container.read(taskListProvider.notifier).deleteTask('t1');

    final titles =
        container.read(taskListProvider).value!.map((t) => t.title).toList();
    expect(titles, ['Palestra']);
    verify(() => repository.delete('t1')).called(1);
  });

  test('deleteTask reloads the list when the API call fails', () async {
    when(() => repository.list())
        .thenAnswer((_) async => [_task('t1', 'Spesa'), _task('t2', 'Palestra')]);
    when(() => repository.delete('t1'))
        .thenThrow(const ServerFailure('boom'));
    await container.read(taskListProvider.future);

    await container.read(taskListProvider.notifier).deleteTask('t1');

    // list() called again to restore the truth from the server
    verify(() => repository.list()).called(2);
  });

  test('updateTask replaces the modified task in place', () async {
    final original = _task('t1', 'Spesa');
    when(() => repository.list()).thenAnswer((_) async => [original]);
    final done = original.copyWith(status: TaskStatus.done);
    when(() => repository.update(done)).thenAnswer((_) async => done);
    await container.read(taskListProvider.future);

    await container.read(taskListProvider.notifier).updateTask(done);

    expect(container.read(taskListProvider).value!.single.status, TaskStatus.done);
  });
}
