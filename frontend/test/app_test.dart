import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/app.dart';

void main() {
  testWidgets('app boots and shows its name', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartTodoApp()));

    expect(find.text('Smart TODO'), findsOneWidget);
  });
}
