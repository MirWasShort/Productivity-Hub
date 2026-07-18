import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dimens.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../providers/task_filter_notifier.dart';

/// Search field (debounced), single-select status/priority chips and
/// the sort menu. Pure UI over the filter notifier.
class TaskFilterBar extends ConsumerStatefulWidget {
  const TaskFilterBar({super.key});

  @override
  ConsumerState<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends ConsumerState<TaskFilterBar> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String term) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      ref.read(taskFilterProvider.notifier).setSearch(term);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(taskFilterProvider);
    final notifier = ref.read(taskFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('tasks_search'),
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cerca nei task…',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: filter.search == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearch('');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: Dimens.sm),
              PopupMenuButton<(TaskSortField, SortDirection)>(
                key: const Key('tasks_sort'),
                icon: const Icon(Icons.sort),
                tooltip: 'Ordina',
                onSelected: (choice) => notifier.setSort(choice.$1, choice.$2),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    key: Key('sort_created_desc'),
                    value: (TaskSortField.createdAt, SortDirection.desc),
                    child: Text('Più recenti'),
                  ),
                  PopupMenuItem(
                    key: Key('sort_due_date'),
                    value: (TaskSortField.dueDate, SortDirection.asc),
                    child: Text('Scadenza più vicina'),
                  ),
                  PopupMenuItem(
                    key: Key('sort_priority'),
                    value: (TaskSortField.priority, SortDirection.desc),
                    child: Text('Priorità più alta'),
                  ),
                  PopupMenuItem(
                    key: Key('sort_title'),
                    value: (TaskSortField.title, SortDirection.asc),
                    child: Text('Titolo A-Z'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimens.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  key: const Key('filter_status_todo'),
                  label: const Text('Da fare'),
                  selected: filter.status == TaskStatus.todo,
                  onSelected: (_) => notifier.toggleStatus(TaskStatus.todo),
                ),
                const SizedBox(width: Dimens.sm),
                FilterChip(
                  key: const Key('filter_status_in_progress'),
                  label: const Text('In corso'),
                  selected: filter.status == TaskStatus.inProgress,
                  onSelected: (_) =>
                      notifier.toggleStatus(TaskStatus.inProgress),
                ),
                const SizedBox(width: Dimens.sm),
                FilterChip(
                  key: const Key('filter_status_done'),
                  label: const Text('Completati'),
                  selected: filter.status == TaskStatus.done,
                  onSelected: (_) => notifier.toggleStatus(TaskStatus.done),
                ),
                const SizedBox(width: Dimens.md),
                FilterChip(
                  key: const Key('filter_priority_high'),
                  label: const Text('Alta priorità'),
                  selected: filter.priority == TaskPriority.high,
                  onSelected: (_) => notifier.togglePriority(TaskPriority.high),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
