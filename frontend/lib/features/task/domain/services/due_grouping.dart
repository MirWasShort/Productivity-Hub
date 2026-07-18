import '../entities/task.dart';

/// Ordered buckets for the smart due-date grouping. Completed tasks
/// always collapse into their own final section, whatever their date:
/// urgency grouping is for work still to do.
enum DueGroup { overdue, today, tomorrow, thisWeek, later, noDate, completed }

const dueGroupLabels = {
  DueGroup.overdue: 'In ritardo',
  DueGroup.today: 'Oggi',
  DueGroup.tomorrow: 'Domani',
  DueGroup.thisWeek: 'Questa settimana',
  DueGroup.later: 'Più avanti',
  DueGroup.noDate: 'Senza scadenza',
  DueGroup.completed: 'Completati',
};

final class DueSection {
  const DueSection(this.group, this.tasks);

  final DueGroup group;
  final List<Task> tasks;

  String get label => dueGroupLabels[group]!;
}

/// The single overdue rule, shared by grouping, card highlighting and
/// (conceptually) the backend analytics: past due AND not done.
bool isOverdue(Task task, DateTime now) =>
    task.status != TaskStatus.done &&
    task.dueDate != null &&
    task.dueDate!.toLocal().isBefore(now);

/// Pure function: buckets tasks into ordered sections using LOCAL
/// calendar-day boundaries. Empty sections are omitted.
List<DueSection> groupByDue(List<Task> tasks, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);

  DueGroup classify(Task task) {
    if (task.status == TaskStatus.done) {
      return DueGroup.completed;
    }
    final due = task.dueDate?.toLocal();
    if (due == null) {
      return DueGroup.noDate;
    }
    if (due.isBefore(now)) {
      return DueGroup.overdue;
    }
    final dueDay = DateTime(due.year, due.month, due.day);
    final daysAhead = dueDay.difference(today).inDays;
    return switch (daysAhead) {
      0 => DueGroup.today,
      1 => DueGroup.tomorrow,
      >= 2 && <= 6 => DueGroup.thisWeek,
      _ => DueGroup.later,
    };
  }

  final buckets = <DueGroup, List<Task>>{};
  for (final task in tasks) {
    buckets.putIfAbsent(classify(task), () => []).add(task);
  }

  return [
    for (final group in DueGroup.values)
      if (buckets.containsKey(group)) DueSection(group, buckets[group]!),
  ];
}
