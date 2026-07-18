import 'dashboard_data.dart';

class WeekBucket {
  const WeekBucket({required this.label, required this.count});

  final String label;
  final int count;
}

/// Aggregates daily completions into the last [weeks] weekly buckets
/// (oldest first), zero-filling empty weeks. 42 daily bars are
/// unreadable; six weekly bars tell the story.
List<WeekBucket> weeklyBuckets(
  List<DayCount> completions,
  DateTime now, {
  int weeks = 6,
}) {
  final today = DateTime(now.year, now.month, now.day);
  // Monday of the current week.
  final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));

  final buckets = List.generate(weeks, (i) {
    final weekStart =
        startOfThisWeek.subtract(Duration(days: 7 * (weeks - 1 - i)));
    return (start: weekStart, count: 0);
  });

  final counts = List<int>.filled(weeks, 0);
  for (final day in completions) {
    final date = DateTime.parse(day.date);
    for (var i = 0; i < weeks; i++) {
      final weekStart = buckets[i].start;
      final weekEnd = weekStart.add(const Duration(days: 7));
      if (!date.isBefore(weekStart) && date.isBefore(weekEnd)) {
        counts[i] += day.count;
        break;
      }
    }
  }

  return [
    for (var i = 0; i < weeks; i++)
      WeekBucket(
        label: '${buckets[i].start.day}/${buckets[i].start.month}',
        count: counts[i],
      ),
  ];
}
