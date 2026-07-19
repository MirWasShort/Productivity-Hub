import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../task/presentation/widgets/task_card.dart';
import '../../domain/calendar_grouping.dart';
import '../providers/calendar_notifier.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final tasksAsync = ref.watch(calendarTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      floatingActionButton: FloatingActionButton(
        key: const Key('calendar_fab'),
        // Prefill the new task's due date with the selected day.
        onPressed: () => context.push(
          '/tasks/new?date=${_isoDay(calendar.selectedDay)}',
        ),
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (tasks) {
          final byDay = groupTasksByDay(tasks);
          final dayTasks = tasksOn(tasks, calendar.selectedDay);

          // A single scroll view: the calendar and the day's tasks scroll
          // together, so small screens never overflow.
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              TableCalendar<void>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2032),
                focusedDay: calendar.focusedDay,
                calendarFormat: calendar.format,
                // By default the button shows the format you'd switch TO,
                // which reads as the view being out of sync with its label.
                headerStyle:
                    const HeaderStyle(formatButtonShowsNext: false),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mese',
                  CalendarFormat.twoWeeks: '2 settimane',
                  CalendarFormat.week: 'Settimana',
                },
                selectedDayPredicate: (day) =>
                    isSameDay(day, calendar.selectedDay),
                eventLoader: (day) =>
                    byDay[DateTime(day.year, day.month, day.day)] ?? const [],
                onDaySelected: notifier.selectDay,
                onFormatChanged: notifier.setFormat,
                onPageChanged: notifier.changeFocus,
              ),
              const Divider(height: 1),
              const SizedBox(height: Dimens.sm),
              if (dayTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: Dimens.xl),
                  child: EmptyState(
                    key: Key('calendar_empty'),
                    icon: Icons.event_available_outlined,
                    title: 'Niente in programma',
                    subtitle: 'Nessun task per il giorno scelto',
                  ),
                )
              else
                for (final task in dayTasks)
                  TaskCard(
                    task: task,
                    onTap: () => context.push('/tasks/${task.id}'),
                  ),
            ],
          );
        },
      ),
    );
  }

  static String _isoDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}
