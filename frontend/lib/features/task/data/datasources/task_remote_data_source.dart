import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(ref.read(dioProvider));
});

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TaskModel>> list({required int page, required int size}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/tasks',
      queryParameters: {'page': page, 'size': size},
    );
    final items = response.data!['items'] as List<dynamic>;
    return items
        .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/tasks/$id');
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> create({
    required String title,
    required String? description,
    required TaskPriority priority,
    required DateTime? dueDate,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tasks',
      data: {
        'title': title,
        'description': description,
        'priority': taskPriorityToJson[priority],
        'dueDate': dueDate?.toUtc().toIso8601String(),
      },
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<TaskModel> update({
    required String id,
    required String title,
    required String? description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime? dueDate,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/tasks/$id',
      data: {
        'title': title,
        'description': description,
        'status': taskStatusToJson[status],
        'priority': taskPriorityToJson[priority],
        'dueDate': dueDate?.toUtc().toIso8601String(),
      },
    );
    return TaskModel.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/v1/tasks/$id');
  }
}
