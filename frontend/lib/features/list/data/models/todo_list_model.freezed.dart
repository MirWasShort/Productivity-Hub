// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodoListModel {

 String get id; String get name; String? get color; int get position;
/// Create a copy of TodoListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoListModelCopyWith<TodoListModel> get copyWith => _$TodoListModelCopyWithImpl<TodoListModel>(this as TodoListModel, _$identity);

  /// Serializes this TodoListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,position);

@override
String toString() {
  return 'TodoListModel(id: $id, name: $name, color: $color, position: $position)';
}


}

/// @nodoc
abstract mixin class $TodoListModelCopyWith<$Res>  {
  factory $TodoListModelCopyWith(TodoListModel value, $Res Function(TodoListModel) _then) = _$TodoListModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? color, int position
});




}
/// @nodoc
class _$TodoListModelCopyWithImpl<$Res>
    implements $TodoListModelCopyWith<$Res> {
  _$TodoListModelCopyWithImpl(this._self, this._then);

  final TodoListModel _self;
  final $Res Function(TodoListModel) _then;

/// Create a copy of TodoListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? position = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoListModel].
extension TodoListModelPatterns on TodoListModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoListModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoListModel value)  $default,){
final _that = this;
switch (_that) {
case _TodoListModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoListModel value)?  $default,){
final _that = this;
switch (_that) {
case _TodoListModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? color,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoListModel() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.position);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? color,  int position)  $default,) {final _that = this;
switch (_that) {
case _TodoListModel():
return $default(_that.id,_that.name,_that.color,_that.position);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? color,  int position)?  $default,) {final _that = this;
switch (_that) {
case _TodoListModel() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoListModel extends TodoListModel {
  const _TodoListModel({required this.id, required this.name, required this.color, required this.position}): super._();
  factory _TodoListModel.fromJson(Map<String, dynamic> json) => _$TodoListModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? color;
@override final  int position;

/// Create a copy of TodoListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoListModelCopyWith<_TodoListModel> get copyWith => __$TodoListModelCopyWithImpl<_TodoListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,position);

@override
String toString() {
  return 'TodoListModel(id: $id, name: $name, color: $color, position: $position)';
}


}

/// @nodoc
abstract mixin class _$TodoListModelCopyWith<$Res> implements $TodoListModelCopyWith<$Res> {
  factory _$TodoListModelCopyWith(_TodoListModel value, $Res Function(_TodoListModel) _then) = __$TodoListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? color, int position
});




}
/// @nodoc
class __$TodoListModelCopyWithImpl<$Res>
    implements _$TodoListModelCopyWith<$Res> {
  __$TodoListModelCopyWithImpl(this._self, this._then);

  final _TodoListModel _self;
  final $Res Function(_TodoListModel) _then;

/// Create a copy of TodoListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = freezed,Object? position = null,}) {
  return _then(_TodoListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
