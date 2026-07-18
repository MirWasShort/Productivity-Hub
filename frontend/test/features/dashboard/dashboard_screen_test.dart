import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/theme/app_theme.dart';
import 'package:smart_todo_app/features/dashboard/data/analytics_repository.dart';
import 'package:smart_todo_app/features/dashboard/presentation/screens/dashboard_screen.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _summary(int total) => Response(
      requestOptions: RequestOptions(path: '/s'),
      statusCode: 200,
      data: {
        'total': total,
        'completed': 4,
        'overdue': 2,
        'dueToday': 1,
        'byStatus': {'TODO': 5, 'IN_PROGRESS': 1, 'DONE': 4},
        'byPriority': {'LOW': 3, 'MEDIUM': 4, 'HIGH': 3},
      },
    );

Response<Map<String, dynamic>> _completions() => Response(
      requestOptions: RequestOptions(path: '/c'),
      statusCode: 200,
      data: {'from': '2026-07-13', 'to': '2026-07-19', 'days': <dynamic>[]},
    );

void main() {
  late _MockDio dio;

  setUp(() {
    dio = _MockDio();
    when(() => dio.get<Map<String, dynamic>>('/api/v1/analytics/completions',
            queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => _completions());
  });

  Widget wrap() => ProviderScope(
        overrides: [
          analyticsRepositoryProvider.overrideWithValue(AnalyticsRepository(dio)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const DashboardScreen()),
      );

  testWidgets('renders the stat tiles with values', (tester) async {
    when(() => dio.get<Map<String, dynamic>>('/api/v1/analytics/summary'))
        .thenAnswer((_) async => _summary(10));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('stat_Totali')), findsOneWidget);
    expect(find.byKey(const Key('stat_Completati')), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Completati per settimana'), findsOneWidget);
  });

  testWidgets('shows the empty state when there is no data', (tester) async {
    when(() => dio.get<Map<String, dynamic>>('/api/v1/analytics/summary'))
        .thenAnswer((_) async => _summary(0));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard_empty')), findsOneWidget);
  });
}
