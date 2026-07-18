import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/entities/task_filter.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _emptyPage() => Response(
      requestOptions: RequestOptions(path: '/api/v1/tasks'),
      statusCode: 200,
      data: {'items': <dynamic>[], 'page': 0, 'size': 50, 'totalElements': 0, 'totalPages': 0},
    );

void main() {
  late _MockDio dio;
  late TaskRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = TaskRemoteDataSource(dio);
  });

  test('serializes the active filter into wire query params', () async {
    when(() => dio.get<Map<String, dynamic>>(any(),
            queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => _emptyPage());

    final filter = const TaskFilter().copyWith(
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      search: 'spesa',
      sortBy: TaskSortField.dueDate,
      direction: SortDirection.asc,
    );

    await dataSource.list(page: 0, size: 50, filter: filter);

    final captured = verify(() => dio.get<Map<String, dynamic>>(any(),
            queryParameters: captureAny(named: 'queryParameters')))
        .captured
        .single as Map<String, dynamic>;
    expect(captured['status'], 'IN_PROGRESS');
    expect(captured['priority'], 'HIGH');
    expect(captured['search'], 'spesa');
    expect(captured['sortBy'], 'DUE_DATE');
    expect(captured['direction'], 'ASC');
  });

  test('omits inactive filter params entirely', () async {
    when(() => dio.get<Map<String, dynamic>>(any(),
            queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => _emptyPage());

    await dataSource.list(page: 0, size: 50, filter: const TaskFilter());

    final captured = verify(() => dio.get<Map<String, dynamic>>(any(),
            queryParameters: captureAny(named: 'queryParameters')))
        .captured
        .single as Map<String, dynamic>;
    expect(captured.containsKey('status'), isFalse);
    expect(captured.containsKey('priority'), isFalse);
    expect(captured.containsKey('search'), isFalse);
    // default sort still sent explicitly: the API default matches, but
    // being explicit keeps client and server independent
    expect(captured['sortBy'], 'CREATED_AT');
    expect(captured['direction'], 'DESC');
  });
}
