import '../entities/todo_list.dart';

abstract interface class ListRepository {
  Future<List<TodoList>> list();

  Future<TodoList> create({required String name, String? color});

  Future<TodoList> update({
    required String id,
    required String name,
    String? color,
  });

  Future<void> delete(String id);
}
