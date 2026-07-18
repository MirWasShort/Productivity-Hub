import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/todo_list.dart';
import '../../domain/repositories/list_repository.dart';
import '../datasources/list_remote_data_source.dart';

final listRepositoryProvider = Provider<ListRepository>((ref) {
  return ListRepositoryImpl(ref.read(listRemoteDataSourceProvider));
});

class ListRepositoryImpl implements ListRepository {
  ListRepositoryImpl(this._dataSource);

  final ListRemoteDataSource _dataSource;

  @override
  Future<List<TodoList>> list() => _guard(() async {
        final models = await _dataSource.list();
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<TodoList> create({required String name, String? color}) => _guard(
      () async => (await _dataSource.create(name: name, color: color)).toEntity());

  @override
  Future<TodoList> update({
    required String id,
    required String name,
    String? color,
  }) =>
      _guard(() async =>
          (await _dataSource.update(id: id, name: name, color: color)).toEntity());

  @override
  Future<void> delete(String id) => _guard(() => _dataSource.delete(id));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw Failure.fromDio(e);
    }
  }
}
