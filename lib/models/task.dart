import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tasks_manager/models/priority_model.dart';
import 'package:tasks_manager/models/priorities.dart' as priorities;

final formatter = DateFormat.yMd();

class Task {
  const Task({
    required this.id,
    required this.name,
    required this.priority,
    required this.date,
  });

  final String id;
  final String name;
  final Priority priority;
  final DateTime date;

  String get formattedDate => formatter.format(date);

  /// Firestore and "Task" are not compatible so a->b and b->a methods are needed
  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    final prio = priorities.priority.values.firstWhere(
      (p) => p.prio == data['priority'],
      orElse: () => priorities.priority[Prios.medium]!,
    );

    final rawDate = data['date'];
    final date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return Task(
      id: id,
      name: data['name'] as String? ?? '',
      priority: prio,
      date: date,
    );
  }

  /// Converts this task into a Firestore-friendly map
  Map<String, dynamic> toFirestore(String userId) {
    return {
      'name': name,
      'priority': priority.prio,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }
}
