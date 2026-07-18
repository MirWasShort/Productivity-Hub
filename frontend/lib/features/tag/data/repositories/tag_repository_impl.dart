import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_data_source.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(ref.read(tagRemoteDataSourceProvider));
});

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._dataSource);

  final TagRemoteDataSource _dataSource;

  @override
  Future<List<Tag>> list() => _guard(() async {
        final models = await _dataSource.list();
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<Tag> create({required String name, String? color}) => _guard(
      () async => (await _dataSource.create(name: name, color: color)).toEntity());

  @override
  Future<Tag> update({required String id, required String name, String? color}) =>
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
