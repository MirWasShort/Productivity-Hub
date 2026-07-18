import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/dashboard/data/analytics_repository.dart';
import 'package:smart_todo_app/features/dashboard/domain/dashboard_data.dart';
import 'package:smart_todo_app/features/dashboard/domain/weekly_completions.dart';
import 'package:smart_todo_app/features/dashboard/presentation/providers/dashboard_notifier.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _summaryResponse() => Response(
      requestOptions: RequestOptions(path: '/api/v1/analytics/summary'),
      statusCode: 200,
      data: {
        'total': 10,
        'completed': 4,
        'overdue': 2,
        'dueToday': 1,
        'byStatus': {'TODO': 5, 'IN_PROGRESS': 1, 'DONE': 4},
        'byPriority': {'LOW': 3, 'MEDIUM': 4, 'HIGH': 3},
      },
    );

Response<Map<String, dynamic>> _completionsResponse() => Response(
      requestOptions: RequestOptions(path: '/api/v1/analytics/completions'),
      statusCode: 200,
      data: {
        'from': '2026-07-13',
        'to': '2026-07-19',
        'days': [
          {'date': '2026-07-15', 'count': 2},
          {'date': '2026-07-18', 'count': 3},
        ],
      },
    );

void main() {
  late _MockDio dio;

  setUp(() {
    dio = _MockDio();
    when(() => dio.get<Map<String, dynamic>>('/api/v1/analytics/summary'))
        .thenAnswer((_) async => _summaryResponse());
    when(() => dio.get<Map<String, dynamic>>('/api/v1/analytics/completions',
            queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => _completionsResponse());
  });

  test('AnalyticsRepository parses summary and completions', () async {
    final repo = AnalyticsRepository(dio);

    final data = await repo.fetch(days: 7);

    expect(data.summary.total, 10);
    expect(data.summary.byPriority['HIGH'], 3);
    expect(data.completions.length, 2);
  });

  test('DashboardData exposes per-day completions keyed by date', () {
    const data = DashboardData(
      summary: AnalyticsSummary(
        total: 1,
        completed: 1,
        overdue: 0,
        dueToday: 0,
        byStatus: {},
        byPriority: {},
      ),
      completions: [DayCount(date: '2026-07-18', count: 3)],
    );

    expect(data.completions.single.count, 3);
  });

  test('weeklyBuckets aggregates daily counts into six zero-filled weeks', () {
    // now = Wednesday 2026-07-15; completions this week and 2 weeks ago.
    final now = DateTime(2026, 7, 15);
    final buckets = weeklyBuckets(const [
      DayCount(date: '2026-07-13', count: 2), // this week (Mon 13)
      DayCount(date: '2026-07-14', count: 1), // this week
      DayCount(date: '2026-06-30', count: 5), // 2 weeks ago
    ], now);

    expect(buckets.length, 6);
    expect(buckets.last.count, 3); // current week: 2 + 1
    expect(buckets.map((b) => b.count).reduce((a, b) => a + b), 8);
  });

  test('dashboardProvider loads via the repository', () async {
    final container = ProviderContainer(overrides: [
      analyticsRepositoryProvider.overrideWithValue(AnalyticsRepository(dio)),
    ]);
    addTearDown(container.dispose);

    final data = await container.read(dashboardProvider.future);

    expect(data.summary.completed, 4);
  });
}
