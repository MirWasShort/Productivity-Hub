import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/tag_model.dart';

final tagRemoteDataSourceProvider = Provider<TagRemoteDataSource>((ref) {
  return TagRemoteDataSource(ref.read(dioProvider));
});

class TagRemoteDataSource {
  TagRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TagModel>> list() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/tags');
    return response.data!
        .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TagModel> create({required String name, String? color}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tags',
      data: {'name': name, 'color': ?color},
    );
    return TagModel.fromJson(response.data!);
  }

  Future<TagModel> update({
    required String id,
    required String name,
    String? color,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/tags/$id',
      data: {'name': name, 'color': ?color},
    );
    return TagModel.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/v1/tags/$id');
  }
}
