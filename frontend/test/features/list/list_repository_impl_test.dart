import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/error/failures.dart';
import 'package:smart_todo_app/features/list/data/datasources/list_remote_data_source.dart';
import 'package:smart_todo_app/features/list/data/models/todo_list_model.dart';
import 'package:smart_todo_app/features/list/data/repositories/list_repository_impl.dart';
import 'package:smart_todo_app/features/list/domain/entities/todo_list.dart';

class _MockDataSource extends Mock implements ListRemoteDataSource {}

const _model = TodoListModel(id: 'l1', name: 'Lavoro', color: '#4F46E5', position: 0);

void main() {
  late _MockDataSource dataSource;
  late ListRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = ListRepositoryImpl(dataSource);
  });

  test('list returns domain entities', () async {
    when(() => dataSource.list()).thenAnswer((_) async => [_model]);

    final lists = await repository.list();

    expect(lists.single, isA<TodoList>());
    expect(lists.single.name, 'Lavoro');
  });

  test('create forwards name and color', () async {
    when(() => dataSource.create(name: 'Casa', color: '#FF0000'))
        .thenAnswer((_) async => _model);

    await repository.create(name: 'Casa', color: '#FF0000');

    verify(() => dataSource.create(name: 'Casa', color: '#FF0000')).called(1);
  });

  test('delete delegates to the datasource', () async {
    when(() => dataSource.delete('l1')).thenAnswer((_) async {});

    await repository.delete('l1');

    verify(() => dataSource.delete('l1')).called(1);
  });

  test('errors become Failures', () async {
    final options = RequestOptions(path: '/api/v1/lists');
    when(() => dataSource.list()).thenThrow(DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: 500),
    ));

    await expectLater(repository.list(), throwsA(isA<ServerFailure>()));
  });
}
