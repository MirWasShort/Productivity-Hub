package com.smarttodo.application.service;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;

import com.smarttodo.application.port.in.GetAnalyticsUseCase;
import com.smarttodo.application.port.out.AnalyticsQueryPort;
import com.smarttodo.application.port.out.AnalyticsQueryPort.AnalyticsSummary;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AnalyticsService implements GetAnalyticsUseCase {

	private static final int MAX_DAYS = 365;

	private final AnalyticsQueryPort analyticsQuery;

	public AnalyticsService(AnalyticsQueryPort analyticsQuery) {
		this.analyticsQuery = analyticsQuery;
	}

	@Override
	@Transactional(readOnly = true)
	public AnalyticsSummaryView summary(UUID userId) {
		AnalyticsSummary s = analyticsQuery.summary(userId, Instant.now());
		return new AnalyticsSummaryView(s.total(), s.completed(), s.overdue(),
				s.dueToday(), s.byStatus(), s.byPriority());
	}

	@Override
	@Transactional(readOnly = true)
	public CompletionsView completions(UUID userId, int days) {
		int clamped = Math.min(Math.max(days, 1), MAX_DAYS);
		Instant since = Instant.now().minus(Duration.ofDays(clamped));
		LocalDate from = LocalDate.ofInstant(since, ZoneOffset.UTC);
		LocalDate to = LocalDate.now(ZoneOffset.UTC);

		var days_ = analyticsQuery.completionsSince(userId, since).stream()
				.map(c -> new DayCount(c.date(), c.count()))
				.toList();
		return new CompletionsView(from, to, days_);
	}
}
