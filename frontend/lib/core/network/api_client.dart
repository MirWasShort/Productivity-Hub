import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Flipped to true by the interceptor when the session cannot be
/// recovered (refresh failed): the router reacts by sending the user
/// back to the login screen.
final sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, bool>(SessionExpiredNotifier.new);

class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void expire() => state = true;

  void reset() => state = false;
}

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );

  final dio = Dio(options);
  // Bare client for the refresh call: no interceptors, no recursion.
  final refreshClient = Dio(options);

  dio.interceptors.add(AuthInterceptor(
    tokenStorage: ref.read(tokenStorageProvider),
    refreshClient: refreshClient,
    retryClient: dio,
    onSessionExpired: () => ref.read(sessionExpiredProvider.notifier).expire(),
  ));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  }

  return dio;
});
