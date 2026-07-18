import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../calendar/presentation/providers/calendar_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../list/presentation/providers/todo_lists_notifier.dart';
import '../../../tag/presentation/providers/tags_notifier.dart';
import '../../../task/presentation/providers/task_filter_notifier.dart';
import '../../../task/presentation/providers/task_list_notifier.dart';
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
        _clearUserScopedData();
        state = const AuthUnauthenticated();
      }
    });
    return const AuthInitial();
  }

  /// Drop every provider that holds the current user's data so the next
  /// session starts clean. Without this the task list, lists, tags,
  /// calendar and dashboard keep the previous user's cached data across a
  /// logout, and the next user sees tasks that aren't theirs.
  void _clearUserScopedData() {
    ref.invalidate(taskListProvider);
    ref.invalidate(taskFilterProvider);
    ref.invalidate(todoListsProvider);
    ref.invalidate(tagsProvider);
    ref.invalidate(calendarTasksProvider);
    ref.invalidate(dashboardProvider);
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
    _clearUserScopedData();
    state = const AuthUnauthenticated();
  }
}
