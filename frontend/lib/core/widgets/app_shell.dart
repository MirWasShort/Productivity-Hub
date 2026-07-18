import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/list/domain/entities/todo_list.dart';
import '../../features/list/presentation/providers/todo_lists_notifier.dart';
import '../../features/list/presentation/widgets/list_editor_dialog.dart';
import '../../features/task/presentation/providers/task_filter_notifier.dart';
import '../theme/dimens.dart';
import '../theme/list_colors.dart';
import '../theme/theme_mode_notifier.dart';

/// Frame shared by the three main tabs. Each branch keeps its own
/// navigation stack and scroll position (indexedStack semantics).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab again resets it to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            key: Key('nav_tasks'),
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Task',
          ),
          NavigationDestination(
            key: Key('nav_calendar'),
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            key: Key('nav_dashboard'),
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}

/// Navigation drawer with the user's lists and app actions. Lives on
/// the tasks tab's Scaffold (where list filtering is relevant) rather
/// than the shell, to avoid the nested-Scaffold drawer problem.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(todoListsProvider);
    final selectedListId = ref.watch(taskFilterProvider).listId;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimens.lg),
              child: Text('Smart TODO',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              key: const Key('drawer_all_tasks'),
              leading: const Icon(Icons.all_inbox_outlined),
              title: const Text('Tutte le attività'),
              selected: selectedListId == null,
              onTap: () {
                ref.read(taskFilterProvider.notifier).setListId(null);
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            Expanded(
              child: lists.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(Dimens.lg),
                  child: Text('$e'),
                ),
                data: (items) => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final list in items)
                      _ListEntry(list: list, selected: list.id == selectedListId),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              key: const Key('drawer_new_list'),
              leading: const Icon(Icons.add),
              title: const Text('Nuova lista'),
              onTap: () => _createList(context, ref),
            ),
            ListTile(
              key: const Key('drawer_manage_tags'),
              leading: const Icon(Icons.label_outline),
              title: const Text('Gestisci tag'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/tags');
              },
            ),
            ListTile(
              leading: Icon(Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              title: const Text('Cambia tema'),
              onTap: () => ref.read(themeModeProvider.notifier).toggle(),
            ),
            ListTile(
              key: const Key('drawer_logout'),
              leading: const Icon(Icons.logout),
              title: const Text('Esci'),
              onTap: () => ref.read(authNotifierProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<ListEditorResult>(
      context: context,
      builder: (_) => const ListEditorDialog(),
    );
    if (result != null) {
      await ref
          .read(todoListsProvider.notifier)
          .createList(name: result.name, color: result.color);
    }
  }
}

class _ListEntry extends ConsumerWidget {
  const _ListEntry({required this.list, required this.selected});

  final TodoList list;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('drawer_list_${list.id}'),
      leading: CircleAvatar(radius: 8, backgroundColor: colorFromHex(list.color)),
      title: Text(list.name),
      selected: selected,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        tooltip: 'Elimina lista',
        onPressed: () => ref.read(todoListsProvider.notifier).deleteList(list.id),
      ),
      onTap: () {
        ref.read(taskFilterProvider.notifier).setListId(list.id);
        Navigator.of(context).pop();
      },
    );
  }
}
