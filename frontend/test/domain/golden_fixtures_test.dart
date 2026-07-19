import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/features/calendar/domain/calendar_grouping.dart';
import 'package:smart_todo_app/features/dashboard/domain/dashboard_data.dart';
import 'package:smart_todo_app/features/dashboard/domain/weekly_completions.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';
import 'package:smart_todo_app/features/task/domain/services/due_grouping.dart';

/// Le fixture condivise con la webapp: gli stessi casi verificati da entrambe
/// le implementazioni. Se una delle due deriva, questi test lo dicono.
/// Vedi `fixtures/README.md` per la convenzione sulle date.
Map<String, dynamic> loadFixture(String name) {
  final file = File('../fixtures/$name.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

TaskStatus statusFromWire(String wire) => switch (wire) {
      'TODO' => TaskStatus.todo,
      'IN_PROGRESS' => TaskStatus.inProgress,
      'DONE' => TaskStatus.done,
      _ => throw ArgumentError('stato sconosciuto: $wire'),
    };

Task taskFrom(Map<String, dynamic> json) {
  final due = json['dueDate'] as String?;
  return Task(
    id: json['id'] as String,
    title: json['id'] as String,
    status: statusFromWire((json['status'] as String?) ?? 'TODO'),
    priority: TaskPriority.medium,
    dueDate: due == null ? null : DateTime.parse(due),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

String groupName(DueGroup group) => group.name;

void main() {
  group('golden fixture: due grouping', () {
    final fixture = loadFixture('due-grouping');
    for (final raw in fixture['cases'] as List<dynamic>) {
      final testCase = raw as Map<String, dynamic>;
      test(testCase['name'] as String, () {
        final now = DateTime.parse(testCase['now'] as String);
        final tasks = (testCase['tasks'] as List<dynamic>)
            .map((t) => taskFrom(t as Map<String, dynamic>))
            .toList();

        final sections = groupByDue(tasks, now);

        final actual = [
          for (final section in sections)
            {
              'group': groupName(section.group),
              'taskIds': [for (final task in section.tasks) task.id],
            },
        ];
        expect(actual, testCase['expected']);
      });
    }
  });

  group('golden fixture: weekly completions', () {
    final fixture = loadFixture('weekly-completions');
    for (final raw in fixture['cases'] as List<dynamic>) {
      final testCase = raw as Map<String, dynamic>;
      test(testCase['name'] as String, () {
        final now = DateTime.parse(testCase['now'] as String);
        final days = [
          for (final day in testCase['days'] as List<dynamic>)
            DayCount(
              date: (day as Map<String, dynamic>)['date'] as String,
              count: day['count'] as int,
            ),
        ];

        final buckets =
            weeklyBuckets(days, now, weeks: testCase['weeks'] as int);

        final actual = [
          for (final bucket in buckets)
            {'label': bucket.label, 'count': bucket.count},
        ];
        expect(actual, testCase['expected']);
      });
    }
  });

  group('golden fixture: calendar grouping', () {
    final fixture = loadFixture('calendar-grouping');
    for (final raw in fixture['cases'] as List<dynamic>) {
      final testCase = raw as Map<String, dynamic>;
      test(testCase['name'] as String, () {
        final tasks = (testCase['tasks'] as List<dynamic>)
            .map((t) => taskFrom(t as Map<String, dynamic>))
            .toList();

        final byDay = groupTasksByDay(tasks);

        final actual = <String, List<String>>{
          for (final entry in byDay.entries)
            '${entry.key.year.toString().padLeft(4, '0')}-'
                    '${entry.key.month.toString().padLeft(2, '0')}-'
                    '${entry.key.day.toString().padLeft(2, '0')}':
                [for (final task in entry.value) task.id],
        };
        expect(actual, testCase['expectedByDay']);
      });
    }
  });
}
