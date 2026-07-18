package com.smarttodo.application.port.out;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;

/**
 * Driven port for aggregate read queries. Returns framework-free records.
 */
public interface AnalyticsQueryPort {

	AnalyticsSummary summary(UUID userId, Instant now);

	List<DailyCount> completionsSince(UUID userId, Instant since);

	record AnalyticsSummary(
			long total,
			long completed,
			long overdue,
			long dueToday,
			Map<TaskStatus, Long> byStatus,
			Map<TaskPriority, Long> byPriority) {
	}

	record DailyCount(LocalDate date, long count) {
	}
}
