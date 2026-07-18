package com.smarttodo.adapter.out.persistence;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.application.port.out.AnalyticsQueryPort.AnalyticsSummary;
import com.smarttodo.application.port.out.AnalyticsQueryPort.DailyCount;
import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@Import({TestcontainersConfiguration.class, AnalyticsPersistenceAdapter.class,
		TaskPersistenceAdapter.class, UserPersistenceAdapter.class})
class AnalyticsPersistenceAdapterIT {

	@Autowired
	private AnalyticsPersistenceAdapter analytics;

	@Autowired
	private TaskPersistenceAdapter taskAdapter;

	@Autowired
	private UserPersistenceAdapter userAdapter;

	private User alice;
	private User bob;

	@BeforeEach
	void setUp() {
		alice = userAdapter.save(User.createNew("alice@example.com", "pw", "Alice"));
		bob = userAdapter.save(User.createNew("bob@example.com", "pw", "Bob"));
	}

	private Task done(String title) {
		return Task.createNew(alice.id(), title, null, TaskPriority.LOW, null)
				.update(title, null, TaskStatus.DONE, TaskPriority.LOW, null);
	}

	@Test
	void should_countTotalsCompletedAndOverdue_scopedToUser() {
		Instant past = Instant.now().minus(Duration.ofDays(1));
		taskAdapter.save(Task.createNew(alice.id(), "Todo", null, TaskPriority.HIGH, null));
		taskAdapter.save(done("Fatto"));
		taskAdapter.save(Task.createNew(alice.id(), "Scaduto", null, TaskPriority.LOW, past));
		// Bob's task must not leak into Alice's totals.
		taskAdapter.save(Task.createNew(bob.id(), "Di Bob", null, TaskPriority.LOW, null));

		AnalyticsSummary summary = analytics.summary(alice.id(), Instant.now());

		assertThat(summary.total()).isEqualTo(3);
		assertThat(summary.completed()).isEqualTo(1);
		assertThat(summary.overdue()).isEqualTo(1);
		assertThat(summary.byPriority().get(TaskPriority.HIGH)).isEqualTo(1);
	}

	@Test
	void should_countCompletionsPerDay_scopedToUser() {
		taskAdapter.save(done("Uno"));
		taskAdapter.save(done("Due"));

		LocalDate today = LocalDate.now(ZoneOffset.UTC);
		var counts = analytics.completionsSince(alice.id(),
				Instant.now().minus(Duration.ofDays(7)));

		assertThat(counts).anySatisfy((DailyCount c) -> {
			assertThat(c.date()).isEqualTo(today);
			assertThat(c.count()).isGreaterThanOrEqualTo(2);
		});
	}

	@Test
	void should_notCountForeignCompletions() {
		taskAdapter.save(Task.createNew(bob.id(), "Bob done", null, TaskPriority.LOW, null)
				.update("Bob done", null, TaskStatus.DONE, TaskPriority.LOW, null));

		AnalyticsSummary summary = analytics.summary(UUID.fromString(alice.id().toString()),
				Instant.now());

		assertThat(summary.completed()).isZero();
	}
}
