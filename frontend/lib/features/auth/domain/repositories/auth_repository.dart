import '../entities/user.dart';

/// Boundary of the auth feature: what the presentation layer can ask for,
/// in domain terms. Implementations may throw [Failure]s.
abstract interface class AuthRepository {
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> login({required String email, required String password});

  Future<bool> hasSession();

  Future<void> logout();
}
