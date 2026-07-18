import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smart_todo_app/app.dart';
import 'package:smart_todo_app/core/storage/preferences.dart';
import 'package:smart_todo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_todo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_todo_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:smart_todo_app/features/task/domain/repositories/task_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuthRepository authRepository;
  late _MockTaskRepository taskRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    taskRepository = _MockTaskRepository();
    when(() => authRepository.hasSession()).thenAnswer((_) async => true);
    when(() => authRepository.logout()).thenAnswer((_) async {});
    when(() => taskRepository.list()).thenAnswer((_) async => []);
  });

  Future<Widget> wrap() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        taskRepositoryProvider.overrideWithValue(taskRepository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SmartTodoApp(),
    );
  }

  testWidgets('shows a NavigationBar with the three destinations',
      (tester) async {
    await tester.pumpWidget(await wrap());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('nav_tasks')), findsOneWidget);
    expect(find.byKey(const Key('nav_calendar')), findsOneWidget);
    expect(find.byKey(const Key('nav_dashboard')), findsOneWidget);
  });

  testWidgets('tapping Calendario switches to the calendar tab',
      (tester) async {
    await tester.pumpWidget(await wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav_calendar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar_placeholder')), findsOneWidget);
  });

  testWidgets('tapping Dashboard switches to the dashboard tab',
      (tester) async {
    await tester.pumpWidget(await wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav_dashboard')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard_placeholder')), findsOneWidget);
  });

  testWidgets('logging out from a shell tab returns to the login screen',
      (tester) async {
    await tester.pumpWidget(await wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tasks_logout')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
