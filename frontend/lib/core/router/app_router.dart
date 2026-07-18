import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/task/presentation/providers/task_list_notifier.dart';
import '../../features/task/presentation/screens/task_detail_screen.dart';
import '../../features/task/presentation/screens/task_edit_screen.dart';
import '../../features/tag/presentation/screens/tag_management_screen.dart';
import '../../features/task/presentation/screens/task_list_screen.dart';
import '../widgets/app_shell.dart';

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
      // The three main tabs live inside an indexed-stack shell: each
      // branch keeps its own stack and state when switching tabs.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (_, _) => const TaskListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/calendar', builder: (_, _) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/dashboard', builder: (_, _) => const DashboardScreen()),
          ]),
        ],
      ),
      // Detail/editor screens stay outside the shell: full-screen push
      // without the bottom bar.
      GoRoute(
        path: '/tags',
        builder: (_, _) => const TagManagementScreen(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (_, _) => const TaskEditScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (_, state) =>
            TaskDetailScreen(taskId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final task = ref
                  .read(taskListProvider)
                  .value
                  ?.where((t) => t.id == id)
                  .firstOrNull;
              return TaskEditScreen(task: task);
            },
          ),
        ],
      ),
    ],
  );
});
