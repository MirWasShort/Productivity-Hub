import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/task_list_notifier.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei task'),
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
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('tasks_retry'),
                onPressed: () => ref.read(taskListProvider.notifier).refresh(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              key: Key('tasks_empty'),
              icon: Icons.checklist_outlined,
              title: 'Nessun task',
              subtitle: 'Creane uno con il pulsante +',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: Dimens.sm, bottom: 88),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final task = items[index];
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
                    onTap: () => context.go('/tasks/${task.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showQuickAddSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _QuickAddSheet(),
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
              context.go('/tasks/new');
            },
          ),
        ],
      ),
    );
  }
}
