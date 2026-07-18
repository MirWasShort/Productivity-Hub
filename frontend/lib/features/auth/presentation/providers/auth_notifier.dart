import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated([this.user]);

  /// Null right after an app restart: the session exists (tokens are
  /// stored) but the user profile is only known after a fresh login.
  final User? user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    // The interceptor flips this flag when a refresh fails: the session
    // is gone no matter what the UI was doing.
    ref.listen(sessionExpiredProvider, (_, expired) {
      if (expired) {
        ref.read(sessionExpiredProvider.notifier).reset();
        state = const AuthUnauthenticated();
      }
    });
    return const AuthInitial();
  }

  Future<void> checkAuth() async {
    state = const AuthLoading();
    final hasSession = await _repository.hasSession();
    state = hasSession ? const AuthAuthenticated() : const AuthUnauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthAuthenticated(user);
    } on Failure catch (failure) {
      state = AuthError(failure.message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.register(
          email: email, password: password, displayName: displayName);
      state = AuthAuthenticated(user);
    } on Failure catch (failure) {
      state = AuthError(failure.message);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }
}
