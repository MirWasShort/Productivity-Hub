import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo_list.dart';

part 'todo_list_model.freezed.dart';
part 'todo_list_model.g.dart';

@freezed
abstract class TodoListModel with _$TodoListModel {
  const TodoListModel._();

  const factory TodoListModel({
    required String id,
    required String name,
    required String? color,
    required int position,
  }) = _TodoListModel;

  factory TodoListModel.fromJson(Map<String, dynamic> json) =>
      _$TodoListModelFromJson(json);

  TodoList toEntity() =>
      TodoList(id: id, name: name, color: color, position: position);
}
