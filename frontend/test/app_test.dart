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

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.hasSession()).thenAnswer((_) async => false);
  });

  Future<SharedPreferencesWithCache> prefsWith(Map<String, Object> values) {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(values);
    return SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  Future<Widget> wrap({Map<String, Object> prefsValues = const {}}) async {
    final prefs = await prefsWith(prefsValues);
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SmartTodoApp(),
    );
  }

  testWidgets('boots to the login screen when there is no session', (tester) async {
    await tester.pumpWidget(await wrap());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('applies the dark theme when the persisted mode is dark',
      (tester) async {
    await tester.pumpWidget(await wrap(prefsValues: {'theme_mode': 'dark'}));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme, isNotNull);
  });
}
