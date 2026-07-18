import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/features/task/data/models/task_model.dart';
import 'package:smart_todo_app/features/task/domain/entities/task.dart';

void main() {
  final json = {
    'id': 't1',
    'title': 'Comprare il latte',
    'description': 'Intero, non scremato',
    'status': 'IN_PROGRESS',
    'priority': 'HIGH',
    'dueDate': '2026-08-01T10:00:00.000Z',
    'createdAt': '2026-07-18T09:00:00.000Z',
    'updatedAt': '2026-07-18T09:30:00.000Z',
    'listId': 'list-1',
    'tags': [
      {'id': 'tag-1', 'name': 'urgente', 'color': '#FF0000'},
    ],
  };

  test('round-trips the backend TaskResponse contract', () {
    final model = TaskModel.fromJson(json);

    expect(model.title, 'Comprare il latte');
    expect(model.status, TaskStatus.inProgress);
    expect(model.priority, TaskPriority.high);
    expect(model.dueDate, DateTime.parse('2026-08-01T10:00:00.000Z'));
    expect(model.listId, 'list-1');
    expect(model.tags.single.name, 'urgente');
    expect(model.toJson(), json);
  });

  test('tolerates null description and dueDate', () {
    final minimal = Map<String, dynamic>.from(json)
      ..['description'] = null
      ..['dueDate'] = null;

    final model = TaskModel.fromJson(minimal);

    expect(model.description, isNull);
    expect(model.dueDate, isNull);
  });

  test('maps to the domain entity', () {
    final task = TaskModel.fromJson(json).toEntity();

    expect(task, isA<Task>());
    expect(task.status, TaskStatus.inProgress);
    expect(task.priority, TaskPriority.high);
  });
}
