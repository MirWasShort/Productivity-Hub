import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smart_todo_app/core/storage/preferences.dart';
import 'package:smart_todo_app/core/theme/theme_mode_notifier.dart';

Future<SharedPreferencesWithCache> _inMemoryPrefs() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesWithCache prefs;
  late ProviderContainer container;

  setUp(() async {
    prefs = await _inMemoryPrefs();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
  });

  test('defaults to system when nothing is persisted', () {
    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('setMode updates the state and persists the choice', () async {
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('build reads the persisted value', () async {
    await prefs.setString('theme_mode', 'dark');

    final freshContainer = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(freshContainer.dispose);

    expect(freshContainer.read(themeModeProvider), ThemeMode.dark);
  });

  test('toggle flips between light and dark', () async {
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
    await container.read(themeModeProvider.notifier).toggle();

    expect(container.read(themeModeProvider), ThemeMode.dark);

    await container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
