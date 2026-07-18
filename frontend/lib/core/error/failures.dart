import 'package:dio/dio.dart';

/// Domain-level failure the UI can react to, decoupled from Dio.
sealed class Failure {
  const Failure(this.message);

  final String message;

  /// Translates a raw [DioException] into a domain failure, extracting
  /// the backend's ErrorResponse message when present.
  factory Failure.fromDio(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode ?? 0;
        final message = _backendMessage(exception.response);
        return switch (statusCode) {
          401 => UnauthorizedFailure(message ?? 'Not authenticated'),
          404 => NotFoundFailure(message ?? 'Resource not found'),
          _ => ServerFailure(message ?? 'Something went wrong ($statusCode)'),
        };
      default:
        return ServerFailure(exception.message ?? 'Unexpected error');
    }
  }

  static String? _backendMessage(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No connection — check your network');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
