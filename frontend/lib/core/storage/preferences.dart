import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Created asynchronously in main() and injected via ProviderScope
/// overrides, so every consumer gets synchronous cached reads and the
/// first frame already knows the persisted values (no theme flash).
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main()'),
);
