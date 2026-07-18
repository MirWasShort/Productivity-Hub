import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/core/error/failures.dart';

DioException _withResponse(int statusCode, {Map<String, dynamic>? body}) {
  final options = RequestOptions(path: '/api/v1/tasks');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: body,
    ),
  );
}

void main() {
  group('Failure.fromDio', () {
    test('maps connection problems to NetworkFailure', () {
      final failure = Failure.fromDio(DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ));

      expect(failure, isA<NetworkFailure>());
    });

    test('maps timeouts to NetworkFailure', () {
      final failure = Failure.fromDio(DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(failure, isA<NetworkFailure>());
    });

    test('maps 401 to UnauthorizedFailure', () {
      expect(Failure.fromDio(_withResponse(401)), isA<UnauthorizedFailure>());
    });

    test('maps 404 to NotFoundFailure', () {
      expect(Failure.fromDio(_withResponse(404)), isA<NotFoundFailure>());
    });

    test('maps other statuses to ServerFailure with the backend message', () {
      final failure = Failure.fromDio(
        _withResponse(409, body: {'message': 'Email already registered'}),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Email already registered');
    });

    test('falls back to a generic message when the body is not ours', () {
      final failure = Failure.fromDio(_withResponse(500));

      expect(failure, isA<ServerFailure>());
      expect(failure.message, isNotEmpty);
    });
  });
}
