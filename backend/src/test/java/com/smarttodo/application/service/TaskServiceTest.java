package com.smarttodo.application.service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.PageResult;
import com.smarttodo.application.port.in.CreateTaskUseCase.CreateTaskCommand;
import com.smarttodo.application.port.in.UpdateTaskUseCase.UpdateTaskCommand;
import com.smarttodo.application.port.out.TaskRepositoryPort;
import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TaskServiceTest {

	private static final UUID OWNER = UUID.randomUUID();
	private static final UUID STRANGER = UUID.randomUUID();

	private TaskRepositoryPort taskRepository;
	private TaskService taskService;

	@BeforeEach
	void setUp() {
		taskRepository = mock(TaskRepositoryPort.class);
		taskService = new TaskService(taskRepository);
		when(taskRepository.save(any(Task.class))).thenAnswer(inv -> inv.getArgument(0));
	}

	private Task existingTask() {
		return Task.createNew(OWNER, "Spesa", "Latte e uova", TaskPriority.MEDIUM, null);
	}

	@Test
	void should_createTaskWithDefaults_when_minimalCommandGiven() {
		Task created = taskService.create(
				new CreateTaskCommand(OWNER, "Spesa", null, TaskPriority.HIGH, null));

		ArgumentCaptor<Task> saved = ArgumentCaptor.forClass(Task.class);
		verify(taskRepository).save(saved.capture());
		assertThat(saved.getValue().userId()).isEqualTo(OWNER);
		assertThat(saved.getValue().status()).isEqualTo(TaskStatus.TODO);
		assertThat(created.title()).isEqualTo("Spesa");
		assertThat(created.priority()).isEqualTo(TaskPriority.HIGH);
	}

	@Test
	void should_returnTask_when_ownerAsksForIt() {
		Task task = existingTask();
		when(taskRepository.findByIdAndUserId(task.id(), OWNER)).thenReturn(Optional.of(task));

		assertThat(taskService.get(OWNER, task.id())).isEqualTo(task);
	}

	@Test
	void should_throwNotFound_when_taskBelongsToAnotherUser() {
		Task task = existingTask();
		when(taskRepository.findByIdAndUserId(task.id(), STRANGER)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> taskService.get(STRANGER, task.id()))
				.isInstanceOf(ResourceNotFoundException.class);
	}

	@Test
	void should_listOwnTasksPaginated_when_asked() {
		Task task = existingTask();
		when(taskRepository.findAllByUserId(OWNER, 0, 20))
				.thenReturn(new PageResult<>(List.of(task), 0, 20, 1, 1));

		PageResult<Task> page = taskService.list(OWNER, 0, 20);

		assertThat(page.items()).containsExactly(task);
		assertThat(page.totalElements()).isEqualTo(1);
	}

	@Test
	void should_updateFieldsAndKeepIdentity_when_ownerUpdates() {
		Task task = existingTask();
		when(taskRepository.findByIdAndUserId(task.id(), OWNER)).thenReturn(Optional.of(task));

		Task updated = taskService.update(new UpdateTaskCommand(
				OWNER, task.id(), "Spesa grande", "Anche pane",
				TaskStatus.DONE, TaskPriority.LOW, Instant.parse("2026-08-01T10:00:00Z")));

		assertThat(updated.id()).isEqualTo(task.id());
		assertThat(updated.userId()).isEqualTo(OWNER);
		assertThat(updated.title()).isEqualTo("Spesa grande");
		assertThat(updated.status()).isEqualTo(TaskStatus.DONE);
		assertThat(updated.createdAt()).isEqualTo(task.createdAt());
		assertThat(updated.updatedAt()).isAfterOrEqualTo(task.updatedAt());
	}

	@Test
	void should_throwNotFound_when_updatingMissingTask() {
		UUID missing = UUID.randomUUID();
		when(taskRepository.findByIdAndUserId(missing, OWNER)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> taskService.update(new UpdateTaskCommand(
				OWNER, missing, "X", null, TaskStatus.TODO, TaskPriority.LOW, null)))
				.isInstanceOf(ResourceNotFoundException.class);

		verify(taskRepository, never()).save(any());
	}

	@Test
	void should_deleteTask_when_ownerDeletes() {
		Task task = existingTask();
		when(taskRepository.findByIdAndUserId(task.id(), OWNER)).thenReturn(Optional.of(task));

		taskService.delete(OWNER, task.id());

		verify(taskRepository).deleteById(task.id());
	}

	@Test
	void should_throwNotFoundAndNotDelete_when_deletingAnotherUsersTask() {
		Task task = existingTask();
		when(taskRepository.findByIdAndUserId(task.id(), STRANGER)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> taskService.delete(STRANGER, task.id()))
				.isInstanceOf(ResourceNotFoundException.class);

		verify(taskRepository, never()).deleteById(any());
	}
}
