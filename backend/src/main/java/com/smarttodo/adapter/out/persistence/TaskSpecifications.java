package com.smarttodo.adapter.out.persistence;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.smarttodo.application.port.in.ListTasksUseCase.SortDirection;
import com.smarttodo.application.port.in.ListTasksUseCase.TaskQuery;
import com.smarttodo.domain.model.TaskPriority;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Order;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.data.jpa.domain.Specification;

/**
 * Translates the framework-free TaskQuery into a JPA Specification.
 * The ORDER BY is built here too (inside toPredicate) because the
 * semantic priority sort needs a CASE expression the Pageable Sort API
 * cannot express — the caller must pass an unsorted PageRequest.
 */
final class TaskSpecifications {

	private TaskSpecifications() {
	}

	static Specification<TaskJpaEntity> from(UUID userId, TaskQuery query) {
		return (root, criteriaQuery, cb) -> {
			List<Predicate> predicates = new ArrayList<>();
			predicates.add(cb.equal(root.get("userId"), userId));

			if (query.status() != null) {
				predicates.add(cb.equal(root.get("status"), query.status()));
			}
			if (query.priority() != null) {
				predicates.add(cb.equal(root.get("priority"), query.priority()));
			}
			if (query.search() != null && !query.search().isBlank()) {
				String pattern = "%" + escapeLike(query.search().toLowerCase()) + "%";
				predicates.add(cb.or(
						cb.like(cb.lower(root.get("title")), pattern, '\\'),
						cb.like(cb.lower(cb.coalesce(root.get("description"), "")),
								pattern, '\\')));
			}
			if (query.dueAfter() != null) {
				predicates.add(cb.greaterThanOrEqualTo(root.get("dueDate"), query.dueAfter()));
			}
			if (query.dueBefore() != null) {
				predicates.add(cb.lessThan(root.get("dueDate"), query.dueBefore()));
			}
			if (query.listId() != null) {
				predicates.add(cb.equal(root.get("listId"), query.listId()));
			}
			if (query.tagId() != null) {
				predicates.add(cb.equal(root.join("tags").get("id"), query.tagId()));
				criteriaQuery.distinct(true);
			}

			if (criteriaQuery.getResultType() != Long.class) {
				// Skip ORDER BY on the count query Spring Data runs for totals.
				criteriaQuery.orderBy(buildOrders(root, cb, query));
			}

			return cb.and(predicates.toArray(Predicate[]::new));
		};
	}

	private static List<Order> buildOrders(Root<TaskJpaEntity> root,
			CriteriaBuilder cb, TaskQuery query) {
		boolean ascending = query.direction() == SortDirection.ASC;
		List<Order> orders = new ArrayList<>();

		switch (query.sortBy()) {
			case CREATED_AT -> orders.add(directed(cb, root.get("createdAt"), ascending));
			case TITLE -> orders.add(directed(cb, cb.lower(root.get("title")), ascending));
			case DUE_DATE -> {
				// Tasks without a due date always sink to the bottom.
				Expression<Integer> nullsLast = cb.<Integer>selectCase()
						.when(cb.isNull(root.get("dueDate")), 1)
						.otherwise(0);
				orders.add(cb.asc(nullsLast));
				orders.add(directed(cb, root.get("dueDate"), ascending));
			}
			case PRIORITY -> {
				// The column stores enum names: natural order would be
				// alphabetical (HIGH < LOW < MEDIUM). Rank them explicitly.
				Expression<Integer> rank = cb
						.<TaskPriority, Integer>selectCase(root.get("priority"))
						.when(TaskPriority.HIGH, 3)
						.when(TaskPriority.MEDIUM, 2)
						.otherwise(1);
				orders.add(directed(cb, rank, ascending));
			}
		}

		// Stable tie-breaker.
		orders.add(cb.desc(root.get("createdAt")));
		return orders;
	}

	private static Order directed(CriteriaBuilder cb, Expression<?> expression,
			boolean ascending) {
		return ascending ? cb.asc(expression) : cb.desc(expression);
	}

	private static String escapeLike(String term) {
		return term
				.replace("\\", "\\\\")
				.replace("%", "\\%")
				.replace("_", "\\_");
	}
}
