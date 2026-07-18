import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/priority_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../task/domain/entities/task.dart';
import '../../domain/dashboard_data.dart';
import '../../domain/weekly_completions.dart';
import '../providers/dashboard_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data.summary.total == 0) {
            return const EmptyState(
              key: Key('dashboard_empty'),
              icon: Icons.insights_outlined,
              title: 'Ancora nessun dato',
              subtitle: 'Crea e completa qualche task per vedere le statistiche',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Dimens.lg),
            children: [
              _StatGrid(summary: data.summary),
              const SizedBox(height: Dimens.xl),
              Text('Completati per settimana',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Dimens.md),
              SizedBox(
                height: 200,
                child: _CompletionsBarChart(
                    buckets: weeklyBuckets(data.completions, DateTime.now())),
              ),
              const SizedBox(height: Dimens.xl),
              Text('Task per priorità',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Dimens.md),
              SizedBox(
                height: 200,
                child: _PriorityDonut(byPriority: data.summary.byPriority),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tiles = [
      (label: 'Totali', value: summary.total, color: scheme.primary),
      (label: 'Completati', value: summary.completed, color: scheme.tertiary),
      (label: 'In ritardo', value: summary.overdue, color: scheme.error),
      (label: 'Oggi', value: summary.dueToday, color: scheme.secondary),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Dimens.md,
      crossAxisSpacing: Dimens.md,
      childAspectRatio: 2.4,
      children: [
        for (final tile in tiles)
          Card(
            key: Key('stat_${tile.label}'),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(Dimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${tile.value}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              color: tile.color, fontWeight: FontWeight.bold)),
                  Text(tile.label,
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Single-series magnitude over time: one hue, thin rounded bars,
/// recessive grid.
class _CompletionsBarChart extends StatelessWidget {
  const _CompletionsBarChart({required this.buckets});

  final List<WeekBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxCount = buckets.map((b) => b.count).fold(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxCount == 0 ? 1 : maxCount).toDouble() + 1,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= buckets.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: Dimens.xs),
                  child: Text(buckets[i].label,
                      style: Theme.of(context).textTheme.labelSmall),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: buckets[i].count.toDouble(),
                color: scheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]),
        ],
      ),
    );
  }
}

/// Categorical breakdown by priority — colors follow the priority
/// entity (from the theme extension, legible in both modes).
class _PriorityDonut extends StatelessWidget {
  const _PriorityDonut({required this.byPriority});

  final Map<String, int> byPriority;

  @override
  Widget build(BuildContext context) {
    final pc = Theme.of(context).extension<PriorityColors>() ??
        PriorityColors.light;
    final entries = [
      (label: 'Bassa', value: byPriority['LOW'] ?? 0, priority: TaskPriority.low),
      (
        label: 'Media',
        value: byPriority['MEDIUM'] ?? 0,
        priority: TaskPriority.medium
      ),
      (label: 'Alta', value: byPriority['HIGH'] ?? 0, priority: TaskPriority.high),
    ];
    final total = entries.fold(0, (a, e) => a + e.value);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (final e in entries)
                  if (e.value > 0)
                    PieChartSectionData(
                      value: e.value.toDouble(),
                      title: total == 0
                          ? ''
                          : '${(e.value * 100 / total).round()}%',
                      radius: 48,
                      color: pc.backgroundOf(e.priority),
                      titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: pc.foregroundOf(e.priority)),
                    ),
              ],
            ),
          ),
        ),
        // Legend: identity is never color-alone.
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: pc.backgroundOf(e.priority),
                            shape: BoxShape.circle)),
                    const SizedBox(width: Dimens.sm),
                    Text('${e.label} (${e.value})',
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
