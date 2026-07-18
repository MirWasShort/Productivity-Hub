import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/list_colors.dart';
import '../../../../core/theme/priority_colors.dart';
import '../../domain/entities/task.dart';
import '../../domain/services/due_grouping.dart';
import '../providers/task_list_notifier.dart';

const _priorityLabels = {
  TaskPriority.low: 'BASSA',
  TaskPriority.medium: 'MEDIA',
  TaskPriority.high: 'ALTA',
};

/// The task row: an outlined M3 card with a status checkbox, priority
/// chip and optional due-date line. Priority colors come from the
/// theme extension so they adapt to light/dark automatically.
class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final priorityColors = theme.extension<PriorityColors>() ??
        (theme.brightness == Brightness.dark
            ? PriorityColors.dark
            : PriorityColors.light);
    final isDone = task.status == TaskStatus.done;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimens.sm, vertical: Dimens.xs),
          child: Row(
            children: [
              Checkbox(
                value: isDone,
                shape: const CircleBorder(),
                onChanged: (checked) {
                  final newStatus =
                      checked == true ? TaskStatus.done : TaskStatus.todo;
                  ref
                      .read(taskListProvider.notifier)
                      .updateTask(task.copyWith(status: newStatus));
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: Dimens.xs),
                      Builder(builder: (context) {
                        final overdue = isOverdue(task, DateTime.now());
                        final dateColor = overdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant;
                        return Row(
                          children: [
                            Icon(
                                overdue
                                    ? Icons.warning_amber_outlined
                                    : Icons.event_outlined,
                                size: 14,
                                color: dateColor),
                            const SizedBox(width: Dimens.xs),
                            Text(
                              _formatDate(task.dueDate!.toLocal()),
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: dateColor,
                                  fontWeight:
                                      overdue ? FontWeight.w600 : null),
                            ),
                          ],
                        );
                      }),
                    ],
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: Dimens.xs),
                      Wrap(
                        spacing: Dimens.xs,
                        runSpacing: Dimens.xs,
                        children: [
                          for (final tag in task.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimens.sm, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorFromHex(tag.color)
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(Dimens.radiusSm),
                                border: Border.all(
                                    color: colorFromHex(tag.color)
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Text(tag.name,
                                  style: theme.textTheme.labelSmall),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Dimens.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColors.backgroundOf(task.priority),
                  borderRadius: BorderRadius.circular(Dimens.radiusSm),
                ),
                child: Text(
                  _priorityLabels[task.priority]!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: priorityColors.foregroundOf(task.priority),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
