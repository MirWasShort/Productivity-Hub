/// A user-defined bucket for tasks.
final class TodoList {
  const TodoList({
    required this.id,
    required this.name,
    required this.position,
    this.color,
  });

  final String id;
  final String name;
  final String? color;
  final int position;
}
