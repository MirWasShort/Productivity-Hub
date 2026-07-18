import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';

/// Create (task == null) and edit (task != null) in one screen.
class TaskEditScreen extends ConsumerStatefulWidget {
  const TaskEditScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskStatus _status;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController =
        TextEditingController(text: widget.task?.description);
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);

    final notifier = ref.read(taskListProvider.notifier);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    try {
      if (_isEdit) {
        await notifier.updateTask(widget.task!.copyWith(
          title: title,
          description: description,
          status: _status,
          priority: _priority,
          dueDate: _dueDate,
        ));
      } else {
        await notifier.createTask(
          title: title,
          description: description,
          priority: _priority,
          dueDate: _dueDate,
        );
      }
      if (mounted && context.canPop()) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifica task' : 'Nuovo task')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('task_title'),
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Il titolo è obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('task_description'),
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione (opzionale)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEdit) ...[
                    DropdownButtonFormField<TaskStatus>(
                      key: const Key('task_status'),
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Stato',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: TaskStatus.todo, child: Text('Da fare')),
                        DropdownMenuItem(
                            value: TaskStatus.inProgress,
                            child: Text('In corso')),
                        DropdownMenuItem(
                            value: TaskStatus.done, child: Text('Completato')),
                      ],
                      onChanged: (value) =>
                          setState(() => _status = value ?? _status),
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<TaskPriority>(
                    key: const Key('task_priority'),
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priorità',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: TaskPriority.low, child: Text('Bassa')),
                      DropdownMenuItem(
                          value: TaskPriority.medium, child: Text('Media')),
                      DropdownMenuItem(
                          value: TaskPriority.high, child: Text('Alta')),
                    ],
                    onChanged: (value) =>
                        setState(() => _priority = value ?? _priority),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('task_due_date'),
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.event),
                    label: Text(_dueDate == null
                        ? 'Scadenza (opzionale)'
                        : 'Scade: ${_dueDate!.toLocal().toString().split(' ').first}'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('task_save'),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEdit ? 'Salva' : 'Crea'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
