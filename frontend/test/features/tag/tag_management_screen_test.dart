import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/features/tag/data/repositories/tag_repository_impl.dart';
import 'package:smart_todo_app/features/tag/domain/entities/tag.dart';
import 'package:smart_todo_app/features/tag/domain/repositories/tag_repository.dart';
import 'package:smart_todo_app/features/tag/presentation/screens/tag_management_screen.dart';

class _MockTagRepository extends Mock implements TagRepository {}

const _tag = Tag(id: 't1', name: 'urgente', color: '#FF0000');

void main() {
  late _MockTagRepository repository;

  setUp(() {
    repository = _MockTagRepository();
    when(() => repository.list()).thenAnswer((_) async => [_tag]);
  });

  Widget wrap() => ProviderScope(
        overrides: [tagRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: TagManagementScreen()),
      );

  testWidgets('lists existing tags', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('urgente'), findsOneWidget);
    expect(find.byKey(const Key('tag_row_t1')), findsOneWidget);
  });

  testWidgets('deleting a tag calls the repository', (tester) async {
    when(() => repository.delete('t1')).thenAnswer((_) async {});

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tag_delete_t1')));
    await tester.pumpAndSettle();

    verify(() => repository.delete('t1')).called(1);
  });

  testWidgets('creating a tag from the dialog calls the repository',
      (tester) async {
    when(() => repository.create(name: 'nuovo', color: any(named: 'color')))
        .thenAnswer((_) async => const Tag(id: 't9', name: 'nuovo'));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tag_add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('list_name')), 'nuovo');
    await tester.tap(find.byKey(const Key('list_save')));
    await tester.pumpAndSettle();

    verify(() => repository.create(name: 'nuovo', color: any(named: 'color')))
        .called(1);
  });
}
