import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../domain/dashboard_data.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.read(dioProvider));
});

class AnalyticsRepository {
  AnalyticsRepository(this._dio);

  final Dio _dio;

  Future<DashboardData> fetch({int days = 42}) async {
    try {
      // Both requests in parallel: the dashboard needs both to render.
      final results = await Future.wait([
        _dio.get<Map<String, dynamic>>('/api/v1/analytics/summary'),
        _dio.get<Map<String, dynamic>>('/api/v1/analytics/completions',
            queryParameters: {'days': days}),
      ]);

      final summary = AnalyticsSummary.fromJson(results[0].data!);
      final days_ = (results[1].data!['days'] as List<dynamic>)
          .map((e) => DayCount.fromJson(e as Map<String, dynamic>))
          .toList();
      return DashboardData(summary: summary, completions: days_);
    } on DioException catch (e) {
      throw Failure.fromDio(e);
    }
  }
}
