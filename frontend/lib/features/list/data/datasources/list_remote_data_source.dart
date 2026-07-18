import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/todo_list_model.dart';

final listRemoteDataSourceProvider = Provider<ListRemoteDataSource>((ref) {
  return ListRemoteDataSource(ref.read(dioProvider));
});

class ListRemoteDataSource {
  ListRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TodoListModel>> list() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/lists');
    return response.data!
        .map((e) => TodoListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TodoListModel> create({required String name, String? color}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/lists',
      data: {'name': name, 'color': ?color},
    );
    return TodoListModel.fromJson(response.data!);
  }

  Future<TodoListModel> update({
    required String id,
    required String name,
    String? color,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/lists/$id',
      data: {'name': name, 'color': ?color},
    );
    return TodoListModel.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/v1/lists/$id');
  }
}
