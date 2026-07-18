import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tag.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
abstract class TagModel with _$TagModel {
  const TagModel._();

  const factory TagModel({
    required String id,
    required String name,
    required String? color,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  Tag toEntity() => Tag(id: id, name: name, color: color);
}
