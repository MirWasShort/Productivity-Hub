import 'package:tasks_manager/models/prio.dart';

class Task {
  const Task({
    required this.id,
    required this.name,
    required this.priority,
  });

  final String id;
  final String name;
  final Priority priority;
}
