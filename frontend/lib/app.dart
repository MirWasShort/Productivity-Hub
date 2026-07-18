import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_notifier.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';

class SmartTodoApp extends ConsumerStatefulWidget {
  const SmartTodoApp({super.key});

  @override
  ConsumerState<SmartTodoApp> createState() => _SmartTodoAppState();
}

class _SmartTodoAppState extends ConsumerState<SmartTodoApp> {
  @override
  void initState() {
    super.initState();
    // Resolve the stored session (if any) as soon as the app starts.
    Future.microtask(
        () => ref.read(authNotifierProvider.notifier).checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart TODO',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
