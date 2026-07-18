import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/app.dart';
import 'package:smart_todo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_todo_app/features/auth/presentation/screens/login_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('boots to the login screen when there is no session', (tester) async {
    final repository = _MockAuthRepository();
    when(() => repository.hasSession()).thenAnswer((_) async => false);

    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const SmartTodoApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
