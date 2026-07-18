import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../list/presentation/providers/todo_lists_notifier.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/services/due_grouping.dart';
import '../providers/task_filter_notifier.dart';
import '../providers/task_list_notifier.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final selectedListId = ref.watch(taskFilterProvider).listId;
    final title = selectedListId == null
        ? 'I miei task'
        : ref.watch(todoListsProvider).value
                ?.where((l) => l.id == selectedListId)
                .firstOrNull
                ?.name ??
            'Lista';

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            key: const Key('theme_toggle'),
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            tooltip: 'Cambia tema',
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            key: const Key('tasks_logout'),
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('tasks_fab'),
        onPressed: () => _showQuickAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: Dimens.sm),
          const TaskFilterBar(),
          const SizedBox(height: Dimens.xs),
          Expanded(
            child: tasks.when(
              // Keep showing the previous data while a filter change
              // reloads: no spinner flash on every chip tap.
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const Key('tasks_retry'),
                      onPressed: () =>
                          ref.read(taskListProvider.notifier).refresh(),
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
              data: (items) => _buildList(context, ref, items),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Task> items) {
    final filter = ref.watch(taskFilterProvider);
    if (items.isEmpty) {
      final hasActiveFilter = !filter.isDefault;
      return EmptyState(
        key: const Key('tasks_empty'),
        icon: hasActiveFilter
            ? Icons.filter_alt_off_outlined
            : Icons.checklist_outlined,
        title: hasActiveFilter ? 'Nessun risultato' : 'Nessun task',
        subtitle: hasActiveFilter
            ? 'Prova ad allentare i filtri'
            : 'Creane uno con il pulsante +',
      );
    }

    // Smart grouping only with the default sort: an explicit sort
    // means the user asked for a specific flat order.
    final isDefaultSort = filter.sortBy == TaskSortField.createdAt &&
        filter.direction == SortDirection.desc;
    final entries = <Widget>[];
    if (isDefaultSort) {
      for (final section in groupByDue(items, DateTime.now())) {
        entries.add(_SectionHeader(section: section));
        entries.addAll(section.tasks.map((t) => _dismissibleCard(ref, t)));
      }
    } else {
      entries.addAll(items.map((t) => _dismissibleCard(ref, t)));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: Dimens.sm, bottom: 88),
        children: entries,
      ),
    );
  }

  Widget _dismissibleCard(WidgetRef ref, Task task) {
    return Builder(builder: (context) {
      return Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: Dimens.lg, vertical: Dimens.xs + 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(Dimens.radiusLg),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: Dimens.lg),
          child: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        onDismissed: (_) =>
            ref.read(taskListProvider.notifier).deleteTask(task.id),
        child: TaskCard(
          task: task,
          onTap: () => context.push('/tasks/${task.id}'),
        ),
      );
    });
  }

  Future<void> _showQuickAddSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _QuickAddSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final DueSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdueSection = section.group == DueGroup.overdue;
    final accent = isOverdueSection ? colorScheme.error : colorScheme.primary;

    return Padding(
      key: Key('due_section_${section.group.name}'),
      padding: const EdgeInsets.fromLTRB(
          Dimens.lg + Dimens.xs, Dimens.lg, Dimens.lg, Dimens.xs),
      child: Row(
        children: [
          Text(
            section.label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: Dimens.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimens.sm, vertical: 1),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimens.radiusSm),
            ),
            child: Text(
              '${section.tasks.length}',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      return;
    }
    ref.read(taskListProvider.notifier).createTask(title: title);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('quick_add_title'),
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nuovo task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            key: const Key('quick_add_submit'),
            icon: const Icon(Icons.check),
            onPressed: _submit,
          ),
          IconButton(
            key: const Key('quick_add_more'),
            tooltip: 'Più opzioni',
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/tasks/new');
            },
          ),
        ],
      ),
    );
  }
}
