class AnalyticsSummary {
  const AnalyticsSummary({
    required this.total,
    required this.completed,
    required this.overdue,
    required this.dueToday,
    required this.byStatus,
    required this.byPriority,
  });

  final int total;
  final int completed;
  final int overdue;
  final int dueToday;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      total: json['total'] as int,
      completed: json['completed'] as int,
      overdue: json['overdue'] as int,
      dueToday: json['dueToday'] as int,
      byStatus: _intMap(json['byStatus']),
      byPriority: _intMap(json['byPriority']),
    );
  }

  static Map<String, int> _intMap(dynamic raw) {
    final map = (raw as Map).cast<String, dynamic>();
    return map.map((k, v) => MapEntry(k, (v as num).toInt()));
  }
}

class DayCount {
  const DayCount({required this.date, required this.count});

  final String date;
  final int count;

  factory DayCount.fromJson(Map<String, dynamic> json) => DayCount(
        date: json['date'] as String,
        count: (json['count'] as num).toInt(),
      );
}

class DashboardData {
  const DashboardData({required this.summary, required this.completions});

  final AnalyticsSummary summary;
  final List<DayCount> completions;
}
