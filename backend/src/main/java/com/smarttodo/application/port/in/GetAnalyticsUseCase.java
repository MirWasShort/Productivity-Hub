package com.smarttodo.application.port.in;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;

public interface GetAnalyticsUseCase {

	AnalyticsSummaryView summary(UUID userId);

	CompletionsView completions(UUID userId, int days);

	record AnalyticsSummaryView(
			long total,
			long completed,
			long overdue,
			long dueToday,
			Map<TaskStatus, Long> byStatus,
			Map<TaskPriority, Long> byPriority) {
	}

	record CompletionsView(LocalDate from, LocalDate to, List<DayCount> days) {
	}

	record DayCount(LocalDate date, long count) {
	}
}
