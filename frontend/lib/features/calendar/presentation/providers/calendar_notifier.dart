import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../task/data/repositories/task_repository_impl.dart';
import '../../../task/domain/entities/task.dart';
import '../../../task/domain/entities/task_filter.dart';

/// Calendar tasks are filter-independent: the calendar always shows
/// everything with a due date, regardless of the task-tab filter.
final calendarTasksProvider = FutureProvider<List<Task>>((ref) {
  return ref.read(taskRepositoryProvider).list(filter: const TaskFilter());
});

class CalendarState {
  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    required this.format,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat format;

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarFormat? format,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      format: format ?? this.format,
    );
  }
}

final calendarProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      focusedDay: now,
      selectedDay: DateTime(now.year, now.month, now.day),
      format: CalendarFormat.month,
    );
  }

  void selectDay(DateTime selected, DateTime focused) {
    state = state.copyWith(selectedDay: selected, focusedDay: focused);
  }

  void changeFocus(DateTime focused) {
    state = state.copyWith(focusedDay: focused);
  }

  void setFormat(CalendarFormat format) {
    state = state.copyWith(format: format);
  }
}
