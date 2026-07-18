import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';

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
            return const Center(
              key: Key('tasks_empty'),
              child: Text('Nessun task — creane uno con +'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _TaskTile(task: items[index]),
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
        ],
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  static const _priorityColors = {
    TaskPriority.low: Colors.green,
    TaskPriority.medium: Colors.orange,
    TaskPriority.high: Colors.red,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(taskListProvider.notifier).deleteTask(task.id),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: (checked) {
            final newStatus =
                checked == true ? TaskStatus.done : TaskStatus.todo;
            ref
                .read(taskListProvider.notifier)
                .updateTask(task.copyWith(status: newStatus));
          },
        ),
        title: Text(
          task.title,
          style: isDone
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: task.description == null ? null : Text(task.description!),
        trailing: Chip(
          label: Text(task.priority.name.toUpperCase(),
              style: const TextStyle(fontSize: 11)),
          backgroundColor:
              _priorityColors[task.priority]!.withValues(alpha: 0.15),
          side: BorderSide(color: _priorityColors[task.priority]!),
        ),
      ),
    );
  }
}
