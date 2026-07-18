import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/network/auth_interceptor.dart';
import 'package:smart_todo_app/core/storage/token_storage.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockDio extends Mock implements Dio {}

class _MockRequestHandler extends Mock implements RequestInterceptorHandler {}

class _MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

DioException _unauthorized(String path) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: 401),
  );
}

void main() {
  late _MockTokenStorage tokenStorage;
  late _MockDio refreshClient;
  late _MockDio retryClient;
  late bool sessionExpired;
  late AuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(_unauthorized('/'));
  });

  setUp(() {
    tokenStorage = _MockTokenStorage();
    refreshClient = _MockDio();
    retryClient = _MockDio();
    sessionExpired = false;
    interceptor = AuthInterceptor(
      tokenStorage: tokenStorage,
      refreshClient: refreshClient,
      retryClient: retryClient,
      onSessionExpired: () => sessionExpired = true,
    );
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    when(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
  });

  group('onRequest', () {
    test('attaches the Bearer header when a token is stored', () async {
      when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => 'acc-123');
      final options = RequestOptions(path: '/api/v1/tasks');
      final handler = _MockRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer acc-123');
      verify(() => handler.next(options)).called(1);
    });

    test('leaves the request untouched when no token is stored', () async {
      when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);
      final options = RequestOptions(path: '/api/v1/auth/login');
      final handler = _MockRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });
  });

  group('onError', () {
    test('passes non-401 errors through', () async {
      final options = RequestOptions(path: '/api/v1/tasks');
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 500),
      );
      final handler = _MockErrorHandler();

      await interceptor.onError(error, handler);

      verify(() => handler.next(error)).called(1);
      verifyZeroInteractions(refreshClient);
    });

    test('does not try to refresh when the 401 comes from an auth endpoint', () async {
      final error = _unauthorized('/api/v1/auth/login');
      final handler = _MockErrorHandler();

      await interceptor.onError(error, handler);

      verify(() => handler.next(error)).called(1);
      verifyZeroInteractions(refreshClient);
    });

    test('refreshes, saves the new pair and replays the request on 401', () async {
      when(() => tokenStorage.readRefreshToken()).thenAnswer((_) async => 'ref-old');
      when(() => refreshClient.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
            statusCode: 200,
            data: {'accessToken': 'acc-new', 'refreshToken': 'ref-new'},
          ));
      final replayed = Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/v1/tasks'),
        statusCode: 200,
      );
      when(() => retryClient.fetch<dynamic>(any())).thenAnswer((_) async => replayed);

      final error = _unauthorized('/api/v1/tasks');
      final handler = _MockErrorHandler();

      await interceptor.onError(error, handler);

      verify(() => tokenStorage.saveTokens(
            accessToken: 'acc-new',
            refreshToken: 'ref-new',
          )).called(1);
      final captured =
          verify(() => retryClient.fetch<dynamic>(captureAny())).captured.single
              as RequestOptions;
      expect(captured.headers['Authorization'], 'Bearer acc-new');
      verify(() => handler.resolve(replayed)).called(1);
      expect(sessionExpired, isFalse);
    });

    test('clears tokens and signals expiry when the refresh fails', () async {
      when(() => tokenStorage.readRefreshToken()).thenAnswer((_) async => 'ref-dead');
      when(() => refreshClient.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_unauthorized('/api/v1/auth/refresh'));

      final error = _unauthorized('/api/v1/tasks');
      final handler = _MockErrorHandler();

      await interceptor.onError(error, handler);

      verify(() => tokenStorage.clear()).called(1);
      expect(sessionExpired, isTrue);
      verify(() => handler.next(error)).called(1);
    });

    test('signals expiry directly when there is no refresh token', () async {
      when(() => tokenStorage.readRefreshToken()).thenAnswer((_) async => null);

      final error = _unauthorized('/api/v1/tasks');
      final handler = _MockErrorHandler();

      await interceptor.onError(error, handler);

      verify(() => tokenStorage.clear()).called(1);
      expect(sessionExpired, isTrue);
      verify(() => handler.next(error)).called(1);
      verifyZeroInteractions(refreshClient);
    });
  });
}
