import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/error/failures.dart';
import 'package:smart_todo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_todo_app/features/auth/domain/entities/user.dart';
import 'package:smart_todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_todo_app/features/auth/presentation/providers/auth_notifier.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = User(id: 'u1', email: 'mario@example.com', displayName: 'Mario');

void main() {
  late _MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockAuthRepository();
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  AuthNotifier notifier() => container.read(authNotifierProvider.notifier);

  test('starts in the initial state', () {
    expect(container.read(authNotifierProvider), isA<AuthInitial>());
  });

  test('checkAuth moves to authenticated when a session exists', () async {
    when(() => repository.hasSession()).thenAnswer((_) async => true);

    await notifier().checkAuth();

    expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());
  });

  test('checkAuth moves to unauthenticated when no session exists', () async {
    when(() => repository.hasSession()).thenAnswer((_) async => false);

    await notifier().checkAuth();

    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
  });

  test('login success carries the user into the authenticated state', () async {
    when(() => repository.login(email: 'mario@example.com', password: 'pw'))
        .thenAnswer((_) async => _user);

    await notifier().login(email: 'mario@example.com', password: 'pw');

    final state = container.read(authNotifierProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user?.displayName, 'Mario');
  });

  test('login failure surfaces the failure message', () async {
    when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const UnauthorizedFailure('Invalid email or password'));

    await notifier().login(email: 'mario@example.com', password: 'wrong');

    final state = container.read(authNotifierProvider);
    expect(state, isA<AuthError>());
    expect((state as AuthError).message, 'Invalid email or password');
  });

  test('register success authenticates with the new user', () async {
    when(() => repository.register(
          email: 'new@example.com',
          password: 'Password1!',
          displayName: 'Nuovo',
        )).thenAnswer((_) async => _user);

    await notifier().register(
        email: 'new@example.com', password: 'Password1!', displayName: 'Nuovo');

    expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());
  });

  test('logout clears the session and moves to unauthenticated', () async {
    when(() => repository.logout()).thenAnswer((_) async {});

    await notifier().logout();

    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    verify(() => repository.logout()).called(1);
  });
}
