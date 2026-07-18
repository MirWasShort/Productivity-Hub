import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Attaches the access token to every request and transparently refreshes
/// it on 401, replaying the failed request.
///
/// Extends [QueuedInterceptor] so concurrent 401s wait for one refresh
/// instead of racing each other. The refresh call itself goes through a
/// separate bare [Dio] ([refreshClient]) — running it through the
/// intercepted client would recurse into this same handler forever.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._tokenStorage,
    required this._refreshClient,
    required this._retryClient,
    required this._onSessionExpired,
  });

  final TokenStorage _tokenStorage;
  final Dio _refreshClient;
  final Dio _retryClient;
  final void Function() _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');
    if (!isUnauthorized || isAuthEndpoint) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      await _expireSession();
      handler.next(err);
      return;
    }

    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data!;
      final newAccessToken = body['accessToken'] as String;
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: body['refreshToken'] as String,
      );

      final replayed = await _retryClient.fetch<dynamic>(
        err.requestOptions..headers['Authorization'] = 'Bearer $newAccessToken',
      );
      handler.resolve(replayed);
    } on DioException {
      await _expireSession();
      handler.next(err);
    }
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clear();
    _onSessionExpired();
  }
}
