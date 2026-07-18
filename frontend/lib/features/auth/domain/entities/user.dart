/// Authenticated user as the rest of the app sees it. Pure Dart, no JSON.
final class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;
}
