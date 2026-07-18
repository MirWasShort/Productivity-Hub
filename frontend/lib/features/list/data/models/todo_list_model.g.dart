// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoListModel _$TodoListModelFromJson(Map<String, dynamic> json) =>
    _TodoListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$TodoListModelToJson(_TodoListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'position': instance.position,
    };
