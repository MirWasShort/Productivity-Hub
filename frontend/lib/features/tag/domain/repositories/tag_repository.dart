import '../entities/tag.dart';

abstract interface class TagRepository {
  Future<List<Tag>> list();

  Future<Tag> create({required String name, String? color});

  Future<Tag> update({required String id, required String name, String? color});

  Future<void> delete(String id);
}
