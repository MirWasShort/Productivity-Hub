import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/widgets/app_shell.dart';
import 'package:smart_todo_app/features/list/data/repositories/list_repository_impl.dart';
import 'package:smart_todo_app/features/list/domain/entities/todo_list.dart';
import 'package:smart_todo_app/features/list/domain/repositories/list_repository.dart';
import 'package:smart_todo_app/features/task/presentation/providers/task_filter_notifier.dart';

class _MockListRepository extends Mock implements ListRepository {}

const _lists = [
  TodoList(id: 'l1', name: 'Lavoro', color: '#4F46E5', position: 0),
  TodoList(id: 'l2', name: 'Casa', color: '#10B981', position: 1),
];

void main() {
  late _MockListRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockListRepository();
    when(() => repository.list()).thenAnswer((_) async => _lists);
    container = ProviderContainer(overrides: [
      listRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  Widget wrap() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(drawer: AppDrawer(), body: SizedBox.shrink()),
      ),
    );
  }

  testWidgets('shows the user lists', (tester) async {
    await tester.pumpWidget(wrap());
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer_list_l1')), findsOneWidget);
    expect(find.text('Lavoro'), findsOneWidget);
    expect(find.text('Casa'), findsOneWidget);
    expect(find.byKey(const Key('drawer_all_tasks')), findsOneWidget);
  });

  testWidgets('selecting a list sets the filter listId', (tester) async {
    await tester.pumpWidget(wrap());
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('drawer_list_l2')));
    await tester.pumpAndSettle();

    expect(container.read(taskFilterProvider).listId, 'l2');
  });

  testWidgets('creating a list from the dialog calls the repository',
      (tester) async {
    when(() => repository.create(name: 'Nuova', color: any(named: 'color')))
        .thenAnswer((_) async =>
            const TodoList(id: 'l9', name: 'Nuova', position: 2));

    await tester.pumpWidget(wrap());
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('drawer_new_list')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('list_name')), 'Nuova');
    await tester.tap(find.byKey(const Key('list_save')));
    await tester.pumpAndSettle();

    verify(() => repository.create(name: 'Nuova', color: any(named: 'color')))
        .called(1);
  });
}
