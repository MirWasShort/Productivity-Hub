/// A colored label attachable to tasks.
final class Tag {
  const Tag({required this.id, required this.name, this.color});

  final String id;
  final String name;
  final String? color;

  @override
  bool operator ==(Object other) =>
      other is Tag &&
      other.id == id &&
      other.name == name &&
      other.color == color;

  @override
  int get hashCode => Object.hash(id, name, color);
}
