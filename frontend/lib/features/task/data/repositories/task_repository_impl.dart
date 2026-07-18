import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(taskRemoteDataSourceProvider));
});

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dataSource);

  /// One page is plenty for now; real pagination is a later feature.
  static const _pageSize = 50;

  final TaskRemoteDataSource _dataSource;

  @override
  Future<List<Task>> list({TaskFilter filter = const TaskFilter()}) =>
      _guard(() async {
        final models =
            await _dataSource.list(page: 0, size: _pageSize, filter: filter);
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<Task> getById(String id) =>
      _guard(() async => (await _dataSource.getById(id)).toEntity());

  @override
  Future<Task> create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? listId,
    List<String> tagIds = const [],
  }) =>
      _guard(() async {
        final model = await _dataSource.create(
          title: title,
          description: description,
          priority: priority,
          dueDate: dueDate,
          listId: listId,
          tagIds: tagIds,
        );
        return model.toEntity();
      });

  @override
  Future<Task> update(Task task) => _guard(() async {
        final model = await _dataSource.update(
          id: task.id,
          title: task.title,
          description: task.description,
          status: task.status,
          priority: task.priority,
          dueDate: task.dueDate,
          listId: task.listId,
          tagIds: task.tags.map((t) => t.id).toList(),
        );
        return model.toEntity();
      });

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
