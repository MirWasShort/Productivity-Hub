import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/analytics_repository.dart';
import '../../domain/dashboard_data.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(
        DashboardNotifier.new);

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() =>
      ref.read(analyticsRepositoryProvider).fetch(days: 42);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(analyticsRepositoryProvider).fetch(days: 42));
  }
}
