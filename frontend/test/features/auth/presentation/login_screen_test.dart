import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_todo_app/features/auth/domain/entities/user.dart';
import 'package:smart_todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_todo_app/features/auth/presentation/screens/login_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('renders email, password and the login button', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });

  testWidgets('shows validation errors and does not call the repository on empty submit',
      (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    expect(find.textContaining('mail'), findsWidgets);
    verifyNever(() => repository.login(
        email: any(named: 'email'), password: any(named: 'password')));
  });

  testWidgets('submits the form values to the repository', (tester) async {
    when(() => repository.login(email: 'mario@example.com', password: 'Password1!'))
        .thenAnswer((_) async =>
            const User(id: 'u1', email: 'mario@example.com', displayName: 'Mario'));

    await tester.pumpWidget(wrap());
    await tester.enterText(find.byKey(const Key('login_email')), 'mario@example.com');
    await tester.enterText(find.byKey(const Key('login_password')), 'Password1!');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();

    verify(() => repository.login(email: 'mario@example.com', password: 'Password1!'))
        .called(1);
  });
}
