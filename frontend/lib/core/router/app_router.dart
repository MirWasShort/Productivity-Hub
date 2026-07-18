import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/task/presentation/screens/task_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod -> Listenable: GoRouter re-evaluates redirect
  // whenever the auth state changes, without being recreated (which
  // would lose the navigation stack).
  final refresh = ValueNotifier(0);
  ref.listen(authNotifierProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/tasks',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final onAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      return switch (auth) {
        AuthAuthenticated() => onAuthRoute ? '/tasks' : null,
        AuthUnauthenticated() || AuthError() => onAuthRoute ? null : '/login',
        // Initial/loading: hold position until checkAuth resolves.
        AuthInitial() || AuthLoading() => null,
      };
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/tasks', builder: (_, _) => const TaskListScreen()),
    ],
  );
});
