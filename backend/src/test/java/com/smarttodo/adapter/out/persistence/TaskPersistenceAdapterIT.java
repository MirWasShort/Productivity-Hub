package com.smarttodo.adapter.out.persistence;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.application.port.PageResult;
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
@Import({TestcontainersConfiguration.class, TaskPersistenceAdapter.class,
		UserPersistenceAdapter.class})
class TaskPersistenceAdapterIT {

	@Autowired
	private TaskPersistenceAdapter adapter;

	@Autowired
	private UserPersistenceAdapter userAdapter;

	private User alice;
	private User bob;

	@BeforeEach
	void setUp() {
		alice = userAdapter.save(User.createNew("alice@example.com", "pw", "Alice"));
		bob = userAdapter.save(User.createNew("bob@example.com", "pw", "Bob"));
	}

	@Test
	void should_persistAllFields_when_taskSaved() {
		Task task = Task.createNew(alice.id(), "Spesa", "Latte", TaskPriority.HIGH, null);

		adapter.save(task);

		assertThat(adapter.findByIdAndUserId(task.id(), alice.id()))
				.hasValueSatisfying(found -> {
					assertThat(found.title()).isEqualTo("Spesa");
					assertThat(found.description()).isEqualTo("Latte");
					assertThat(found.status()).isEqualTo(TaskStatus.TODO);
					assertThat(found.priority()).isEqualTo(TaskPriority.HIGH);
				});
	}

	@Test
	void should_scopeLookupToOwner_when_findingById() {
		Task task = Task.createNew(alice.id(), "Privato", null, TaskPriority.MEDIUM, null);
		adapter.save(task);

		assertThat(adapter.findByIdAndUserId(task.id(), bob.id())).isEmpty();
	}

	@Test
	void should_returnOnlyOwnTasksNewestFirst_when_listing() {
		adapter.save(Task.createNew(alice.id(), "Primo", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Secondo", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(bob.id(), "Di Bob", null, TaskPriority.LOW, null));

		PageResult<Task> page = adapter.findAllByUserId(alice.id(), 0, 10);

		assertThat(page.items()).hasSize(2);
		assertThat(page.items()).allSatisfy(t -> assertThat(t.userId()).isEqualTo(alice.id()));
		assertThat(page.totalElements()).isEqualTo(2);
	}

	@Test
	void should_paginate_when_moreTasksThanPageSize() {
		for (int i = 0; i < 5; i++) {
			adapter.save(Task.createNew(alice.id(), "Task " + i, null, TaskPriority.LOW, null));
		}

		PageResult<Task> firstPage = adapter.findAllByUserId(alice.id(), 0, 2);

		assertThat(firstPage.items()).hasSize(2);
		assertThat(firstPage.totalElements()).isEqualTo(5);
		assertThat(firstPage.totalPages()).isEqualTo(3);
	}
}
