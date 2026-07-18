package com.smarttodo.adapter.out.persistence;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.application.port.PageResult;
import com.smarttodo.application.port.in.ListTasksUseCase.SortDirection;
import com.smarttodo.application.port.in.ListTasksUseCase.TaskQuery;
import com.smarttodo.application.port.in.ListTasksUseCase.TaskSortField;
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
		UserPersistenceAdapter.class, TagPersistenceAdapter.class,
		TodoListPersistenceAdapter.class})
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

	private static TaskQuery unfiltered() {
		return TaskQuery.unfiltered();
	}

	private PageResult<Task> search(TaskQuery query) {
		return adapter.search(alice.id(), query, 0, 20);
	}

	// --- basic persistence & scoping (pre-existing behavior) ---

	@Test
	void should_persistAllFields_when_taskSaved() {
		Task task = Task.createNew(alice.id(), "Spesa", "Latte", TaskPriority.HIGH, null);

		adapter.save(task);

		assertThat(adapter.findByIdAndUserId(task.id(), alice.id()))
				.hasValueSatisfying(found -> {
					assertThat(found.title()).isEqualTo("Spesa");
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
	void should_returnOnlyOwnTasks_when_searching() {
		adapter.save(Task.createNew(alice.id(), "Mio", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(bob.id(), "Di Bob", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered());

		assertThat(page.items()).hasSize(1);
		assertThat(page.items().getFirst().title()).isEqualTo("Mio");
	}

	@Test
	void should_paginate_when_moreTasksThanPageSize() {
		for (int i = 0; i < 5; i++) {
			adapter.save(Task.createNew(alice.id(), "Task " + i, null, TaskPriority.LOW, null));
		}

		PageResult<Task> firstPage = adapter.search(alice.id(), unfiltered(), 0, 2);

		assertThat(firstPage.items()).hasSize(2);
		assertThat(firstPage.totalElements()).isEqualTo(5);
		assertThat(firstPage.totalPages()).isEqualTo(3);
	}

	// --- filters ---

	@Test
	void should_filterByStatus_when_statusGiven() {
		adapter.save(Task.createNew(alice.id(), "Da fare", null, TaskPriority.LOW, null));
		Task done = Task.createNew(alice.id(), "Fatto", null, TaskPriority.LOW, null)
				.update("Fatto", null, TaskStatus.DONE, TaskPriority.LOW, null);
		adapter.save(done);

		PageResult<Task> page = search(unfiltered().withStatus(TaskStatus.DONE));

		assertThat(page.items()).extracting(Task::title).containsExactly("Fatto");
	}

	@Test
	void should_filterByPriority_when_priorityGiven() {
		adapter.save(Task.createNew(alice.id(), "Alta", null, TaskPriority.HIGH, null));
		adapter.save(Task.createNew(alice.id(), "Bassa", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered().withPriority(TaskPriority.HIGH));

		assertThat(page.items()).extracting(Task::title).containsExactly("Alta");
	}

	@Test
	void should_matchTitleAndDescriptionCaseInsensitively_when_searching() {
		adapter.save(Task.createNew(alice.id(), "Comprare il LATTE", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Palestra", "portare il latte di mandorla",
				TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Altro", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered().withSearch("latte"));

		assertThat(page.items()).hasSize(2);
	}

	@Test
	void should_escapeLikeWildcards_when_searching() {
		adapter.save(Task.createNew(alice.id(), "Sconto 100%", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Sconto 100 euro", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered().withSearch("100%"));

		assertThat(page.items()).extracting(Task::title).containsExactly("Sconto 100%");
	}

	@Test
	void should_filterByDueRange_when_boundsGiven() {
		Instant now = Instant.now();
		adapter.save(Task.createNew(alice.id(), "Presto", null, TaskPriority.LOW,
				now.plus(Duration.ofDays(1))));
		adapter.save(Task.createNew(alice.id(), "Tardi", null, TaskPriority.LOW,
				now.plus(Duration.ofDays(30))));
		adapter.save(Task.createNew(alice.id(), "Senza data", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered()
				.withDueAfter(now)
				.withDueBefore(now.plus(Duration.ofDays(7))));

		assertThat(page.items()).extracting(Task::title).containsExactly("Presto");
	}

	// --- sorting ---

	@Test
	void should_sortByDueDateWithNullsLast_when_sortingAscending() {
		Instant now = Instant.now();
		adapter.save(Task.createNew(alice.id(), "Dopo", null, TaskPriority.LOW,
				now.plus(Duration.ofDays(5))));
		adapter.save(Task.createNew(alice.id(), "Senza", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Prima", null, TaskPriority.LOW,
				now.plus(Duration.ofDays(1))));

		PageResult<Task> page = search(
				unfiltered().withSort(TaskSortField.DUE_DATE, SortDirection.ASC));

		assertThat(page.items()).extracting(Task::title)
				.containsExactly("Prima", "Dopo", "Senza");
	}

	@Test
	void should_sortPrioritySemantically_when_sortingByPriorityDescending() {
		adapter.save(Task.createNew(alice.id(), "Media", null, TaskPriority.MEDIUM, null));
		adapter.save(Task.createNew(alice.id(), "Bassa", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Alta", null, TaskPriority.HIGH, null));

		PageResult<Task> page = search(
				unfiltered().withSort(TaskSortField.PRIORITY, SortDirection.DESC));

		assertThat(page.items()).extracting(Task::title)
				.containsExactly("Alta", "Media", "Bassa");
	}

	// --- lists & tags on tasks ---

	@Autowired
	private TagPersistenceAdapter tagAdapter;

	@Autowired
	private TodoListPersistenceAdapter listAdapter;

	@Test
	void should_saveAndReloadTags_when_taskHasTags() {
		com.smarttodo.domain.model.Tag tag =
				tagAdapter.save(com.smarttodo.domain.model.Tag.createNew(
						alice.id(), "urgente", "#FF0000"));
		Task task = Task.createNew(alice.id(), "Con tag", null, TaskPriority.LOW, null)
				.withListAndTags(null, List.of(tag));

		adapter.save(task);

		assertThat(adapter.findByIdAndUserId(task.id(), alice.id()))
				.hasValueSatisfying(found -> assertThat(found.tags())
						.extracting(com.smarttodo.domain.model.Tag::name)
						.containsExactly("urgente"));
	}

	@Test
	void should_filterByTagId_when_given() {
		com.smarttodo.domain.model.Tag tag =
				tagAdapter.save(com.smarttodo.domain.model.Tag.createNew(
						alice.id(), "casa", null));
		adapter.save(Task.createNew(alice.id(), "Taggato", null, TaskPriority.LOW, null)
				.withListAndTags(null, List.of(tag)));
		adapter.save(Task.createNew(alice.id(), "Libero", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered().withTagId(tag.id()));

		assertThat(page.items()).extracting(Task::title).containsExactly("Taggato");
	}

	@Test
	void should_filterByListId_when_given() {
		com.smarttodo.domain.model.TodoList list =
				listAdapter.save(com.smarttodo.domain.model.TodoList.createNew(
						alice.id(), "Lavoro", null));
		adapter.save(Task.createNew(alice.id(), "In lista", null, TaskPriority.LOW, null)
				.withListAndTags(list.id(), List.of()));
		adapter.save(Task.createNew(alice.id(), "Fuori", null, TaskPriority.LOW, null));

		PageResult<Task> page = search(unfiltered().withListId(list.id()));

		assertThat(page.items()).extracting(Task::title).containsExactly("In lista");
	}

	@Test
	void should_combineFilters_when_multipleGiven() {
		adapter.save(Task.createNew(alice.id(), "Spesa urgente", null, TaskPriority.HIGH, null));
		adapter.save(Task.createNew(alice.id(), "Spesa calma", null, TaskPriority.LOW, null));
		adapter.save(Task.createNew(alice.id(), "Palestra urgente", null, TaskPriority.HIGH, null));

		PageResult<Task> page = search(
				unfiltered().withSearch("spesa").withPriority(TaskPriority.HIGH));

		assertThat(page.items()).extracting(Task::title).containsExactly("Spesa urgente");
	}
}
