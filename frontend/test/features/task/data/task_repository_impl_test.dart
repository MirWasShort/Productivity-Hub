import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/error/failures.dart';
import 'package:smart_todo_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:smart_todo_app/features/task/data/models/task_model.dart';
import 'package:smart_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/entities/task_filter.dart';

class _MockDataSource extends Mock implements TaskRemoteDataSource {}

final _model = TaskModel(
  id: 't1',
  title: 'Spesa',
  description: null,
  status: TaskStatus.todo,
  priority: TaskPriority.medium,
  dueDate: null,
  createdAt: DateTime.utc(2026, 7, 18, 9),
  updatedAt: DateTime.utc(2026, 7, 18, 9),
);

DioException _dioError(int statusCode) {
  final options = RequestOptions(path: '/api/v1/tasks');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const TaskFilter());
  });

  late _MockDataSource dataSource;
  late TaskRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = TaskRepositoryImpl(dataSource);
  });

  test('list returns domain entities', () async {
    when(() => dataSource.list(
          page: 0,
          size: 50,
          filter: const TaskFilter(),
        )).thenAnswer((_) async => [_model]);

    final tasks = await repository.list();

    expect(tasks, hasLength(1));
    expect(tasks.first, isA<Task>());
    expect(tasks.first.title, 'Spesa');
  });

  test('list forwards the filter to the datasource', () async {
    final filter = const TaskFilter().copyWith(
      status: TaskStatus.todo,
      search: 'spesa',
      sortBy: TaskSortField.dueDate,
      direction: SortDirection.asc,
    );
    when(() => dataSource.list(page: 0, size: 50, filter: filter))
        .thenAnswer((_) async => [_model]);

    final tasks = await repository.list(filter: filter);

    expect(tasks, hasLength(1));
    verify(() => dataSource.list(page: 0, size: 50, filter: filter)).called(1);
  });

  test('create sends the fields and returns the created entity', () async {
    when(() => dataSource.create(
          title: 'Spesa',
          description: null,
          priority: TaskPriority.medium,
          dueDate: null,
        )).thenAnswer((_) async => _model);

    final task = await repository.create(title: 'Spesa');

    expect(task.id, 't1');
  });

  test('update maps the modified entity back to the API', () async {
    final modified = _model.toEntity().copyWith(status: TaskStatus.done);
    when(() => dataSource.update(
          id: 't1',
          title: 'Spesa',
          description: null,
          status: TaskStatus.done,
          priority: TaskPriority.medium,
          dueDate: null,
        )).thenAnswer((_) async => _model);

    final task = await repository.update(modified);

    expect(task, isA<Task>());
  });

  test('delete delegates to the datasource', () async {
    when(() => dataSource.delete('t1')).thenAnswer((_) async {});

    await repository.delete('t1');

    verify(() => dataSource.delete('t1')).called(1);
  });

  test('errors are translated into Failures', () async {
    when(() => dataSource.list(
          page: any(named: 'page'),
          size: any(named: 'size'),
          filter: any(named: 'filter'),
        )).thenThrow(_dioError(500));

    await expectLater(repository.list(), throwsA(isA<ServerFailure>()));
  });

  test('a 404 on getById becomes a NotFoundFailure', () async {
    when(() => dataSource.getById('missing')).thenThrow(_dioError(404));

    await expectLater(repository.getById('missing'), throwsA(isA<NotFoundFailure>()));
  });
}
