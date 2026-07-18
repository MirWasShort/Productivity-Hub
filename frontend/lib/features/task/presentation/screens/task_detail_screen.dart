import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  static const _statusLabels = {
    TaskStatus.todo: 'Da fare',
    TaskStatus.inProgress: 'In corso',
    TaskStatus.done: 'Completato',
  };

  static const _priorityLabels = {
    TaskPriority.low: 'Bassa',
    TaskPriority.medium: 'Media',
    TaskPriority.high: 'Alta',
  };

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminare questo task?'),
        content: const Text('L\'operazione non si può annullare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            key: const Key('detail_delete_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(taskListProvider.notifier).deleteTask(taskId);
      if (context.mounted && context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final task = tasks.value?.where((t) => t.id == taskId).firstOrNull;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: tasks.isLoading
              ? const CircularProgressIndicator()
              : const Text('Task non trovato'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio'),
        actions: [
          IconButton(
            key: const Key('detail_edit'),
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/tasks/${task.id}/edit'),
          ),
          IconButton(
            key: const Key('detail_delete'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (task.description != null) ...[
            Text(task.description!,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
          ],
          _DetailRow(label: 'Stato', value: _statusLabels[task.status]!),
          _DetailRow(label: 'Priorità', value: _priorityLabels[task.priority]!),
          if (task.dueDate != null)
            _DetailRow(
                label: 'Scadenza',
                value: task.dueDate!.toLocal().toString().split(' ').first),
          _DetailRow(
              label: 'Creato',
              value: task.createdAt.toLocal().toString().split('.').first),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
