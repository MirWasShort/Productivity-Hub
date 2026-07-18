import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Wire names of the backend enums (stored as strings in the DB too).
const taskStatusToJson = {
  TaskStatus.todo: 'TODO',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.done: 'DONE',
};

const taskPriorityToJson = {
  TaskPriority.low: 'LOW',
  TaskPriority.medium: 'MEDIUM',
  TaskPriority.high: 'HIGH',
};

TaskStatus taskStatusFromJson(String value) =>
    taskStatusToJson.entries.firstWhere((e) => e.value == value).key;

TaskPriority taskPriorityFromJson(String value) =>
    taskPriorityToJson.entries.firstWhere((e) => e.value == value).key;

String _statusToJson(TaskStatus status) => taskStatusToJson[status]!;

String _priorityToJson(TaskPriority priority) => taskPriorityToJson[priority]!;

/// Mirrors the backend's TaskResponse DTO.
@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    required String? description,
    @JsonKey(fromJson: taskStatusFromJson, toJson: _statusToJson)
    required TaskStatus status,
    @JsonKey(fromJson: taskPriorityFromJson, toJson: _priorityToJson)
    required TaskPriority priority,
    required DateTime? dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Task toEntity() => Task(
        id: id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
