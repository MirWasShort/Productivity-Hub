package com.smarttodo.adapter.out.persistence;

import java.sql.Date;
import java.time.Instant;
import java.time.LocalDate;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.smarttodo.application.port.out.AnalyticsQueryPort;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;
import jakarta.persistence.EntityManager;
import org.springframework.stereotype.Component;

@Component
public class AnalyticsPersistenceAdapter implements AnalyticsQueryPort {

	private final EntityManager em;

	public AnalyticsPersistenceAdapter(EntityManager em) {
		this.em = em;
	}

	@Override
	public AnalyticsSummary summary(UUID userId, Instant now) {
		long total = count("select count(t) from TaskJpaEntity t where t.userId = :u",
				userId);
		long completed = count("select count(t) from TaskJpaEntity t "
				+ "where t.userId = :u and t.status = com.smarttodo.domain.model.TaskStatus.DONE",
				userId);
		long overdue = ((Number) em.createQuery(
						"select count(t) from TaskJpaEntity t where t.userId = :u "
								+ "and t.dueDate < :now "
								+ "and t.status <> com.smarttodo.domain.model.TaskStatus.DONE")
				.setParameter("u", userId).setParameter("now", now)
				.getSingleResult()).longValue();

		LocalDate today = LocalDate.now(java.time.ZoneOffset.UTC);
		Instant startOfToday = today.atStartOfDay(java.time.ZoneOffset.UTC).toInstant();
		Instant startOfTomorrow = today.plusDays(1)
				.atStartOfDay(java.time.ZoneOffset.UTC).toInstant();
		long dueToday = ((Number) em.createQuery(
						"select count(t) from TaskJpaEntity t where t.userId = :u "
								+ "and t.dueDate >= :start and t.dueDate < :end")
				.setParameter("u", userId).setParameter("start", startOfToday)
				.setParameter("end", startOfTomorrow)
				.getSingleResult()).longValue();

		return new AnalyticsSummary(total, completed, overdue, dueToday,
				groupByStatus(userId), groupByPriority(userId));
	}

	@Override
	public List<DailyCount> completionsSince(UUID userId, Instant since) {
		// Native: bucket completed_at by UTC calendar day.
		@SuppressWarnings("unchecked")
		List<Object[]> rows = em.createNativeQuery(
						"select cast(completed_at at time zone 'UTC' as date) as d, count(*) "
								+ "from tasks where user_id = :u and completed_at >= :since "
								+ "group by d order by d")
				.setParameter("u", userId).setParameter("since", since)
				.getResultList();
		return rows.stream()
				.map(r -> new DailyCount(toLocalDate(r[0]), ((Number) r[1]).longValue()))
				.toList();
	}

	private static LocalDate toLocalDate(Object value) {
		// Hibernate may hand back java.sql.Date or java.time.LocalDate
		// depending on driver/version.
		if (value instanceof LocalDate ld) {
			return ld;
		}
		return ((Date) value).toLocalDate();
	}

	private long count(String jpql, UUID userId) {
		return ((Number) em.createQuery(jpql).setParameter("u", userId)
				.getSingleResult()).longValue();
	}

	private Map<TaskStatus, Long> groupByStatus(UUID userId) {
		Map<TaskStatus, Long> map = new EnumMap<>(TaskStatus.class);
		for (TaskStatus s : TaskStatus.values()) {
			map.put(s, 0L);
		}
		List<Object[]> rows = em.createQuery(
						"select t.status, count(t) from TaskJpaEntity t "
								+ "where t.userId = :u group by t.status", Object[].class)
				.setParameter("u", userId).getResultList();
		for (Object[] row : rows) {
			map.put((TaskStatus) row[0], ((Number) row[1]).longValue());
		}
		return map;
	}

	private Map<TaskPriority, Long> groupByPriority(UUID userId) {
		Map<TaskPriority, Long> map = new EnumMap<>(TaskPriority.class);
		for (TaskPriority p : TaskPriority.values()) {
			map.put(p, 0L);
		}
		List<Object[]> rows = em.createQuery(
						"select t.priority, count(t) from TaskJpaEntity t "
								+ "where t.userId = :u group by t.priority", Object[].class)
				.setParameter("u", userId).getResultList();
		for (Object[] row : rows) {
			map.put((TaskPriority) row[0], ((Number) row[1]).longValue());
		}
		return map;
	}
}
