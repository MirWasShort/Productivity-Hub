import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/error/failures.dart';
import 'package:smart_todo_app/features/tag/data/datasources/tag_remote_data_source.dart';
import 'package:smart_todo_app/features/tag/data/models/tag_model.dart';
import 'package:smart_todo_app/features/tag/data/repositories/tag_repository_impl.dart';
import 'package:smart_todo_app/features/tag/domain/entities/tag.dart';

class _MockDataSource extends Mock implements TagRemoteDataSource {}

const _model = TagModel(id: 't1', name: 'urgente', color: '#FF0000');

void main() {
  late _MockDataSource dataSource;
  late TagRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = TagRepositoryImpl(dataSource);
  });

  test('list returns domain entities', () async {
    when(() => dataSource.list()).thenAnswer((_) async => [_model]);

    final tags = await repository.list();

    expect(tags.single, isA<Tag>());
    expect(tags.single.name, 'urgente');
  });

  test('create forwards name and color', () async {
    when(() => dataSource.create(name: 'casa', color: '#00FF00'))
        .thenAnswer((_) async => _model);

    await repository.create(name: 'casa', color: '#00FF00');

    verify(() => dataSource.create(name: 'casa', color: '#00FF00')).called(1);
  });

  test('a 409 duplicate becomes a ServerFailure with the message', () async {
    final options = RequestOptions(path: '/api/v1/tags');
    when(() => dataSource.create(name: any(named: 'name'), color: any(named: 'color')))
        .thenThrow(DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: options,
        statusCode: 409,
        data: {'message': 'Tag already exists: casa'},
      ),
    ));

    await expectLater(
      repository.create(name: 'casa'),
      throwsA(isA<ServerFailure>()
          .having((f) => f.message, 'message', 'Tag already exists: casa')),
    );
  });
}
