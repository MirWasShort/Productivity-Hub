import '../../../tag/domain/entities/tag.dart';

/// Mirrors the backend enums; JSON wire names live in the data layer.
enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

final class Task {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueDate,
    this.listId,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? listId;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    String? listId,
    bool clearListId = false,
    List<Tag>? tags,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      listId: clearListId ? null : (listId ?? this.listId),
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
