package com.smarttodo.application.service;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.PageResult;
import com.smarttodo.application.port.in.CreateTaskUseCase;
import com.smarttodo.application.port.in.DeleteTaskUseCase;
import com.smarttodo.application.port.in.GetTaskUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase.TaskQuery;
import com.smarttodo.application.port.in.UpdateTaskUseCase;
import com.smarttodo.application.port.out.TagRepositoryPort;
import com.smarttodo.application.port.out.TaskRepositoryPort;
import com.smarttodo.application.port.out.TodoListRepositoryPort;
import com.smarttodo.domain.model.Tag;
import com.smarttodo.domain.model.Task;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Every operation is scoped to the authenticated user: a task that exists
 * but belongs to someone else is indistinguishable from a missing one
 * (404, never 403 — no existence leak). The same rule covers referenced
 * lists and tags: pointing at someone else's is a 404.
 */
@Service
public class TaskService implements CreateTaskUseCase, GetTaskUseCase, ListTasksUseCase,
		UpdateTaskUseCase, DeleteTaskUseCase {

	private final TaskRepositoryPort taskRepository;
	private final TagRepositoryPort tagRepository;
	private final TodoListRepositoryPort listRepository;

	public TaskService(TaskRepositoryPort taskRepository, TagRepositoryPort tagRepository,
			TodoListRepositoryPort listRepository) {
		this.taskRepository = taskRepository;
		this.tagRepository = tagRepository;
		this.listRepository = listRepository;
	}

	@Override
	@Transactional
	public Task create(CreateTaskCommand command) {
		requireOwnListIfPresent(command.userId(), command.listId());
		List<Tag> tags = resolveOwnedTags(command.userId(), command.tagIds());

		Task task = Task.createNew(command.userId(), command.title(), command.description(),
						command.priority(), command.dueDate())
				.withListAndTags(command.listId(), tags);
		return taskRepository.save(task);
	}

	@Override
	@Transactional(readOnly = true)
	public Task get(UUID userId, UUID taskId) {
		return requireOwnTask(userId, taskId);
	}

	@Override
	@Transactional(readOnly = true)
	public PageResult<Task> list(UUID userId, TaskQuery query, int page, int size) {
		return taskRepository.search(userId, query, page, size);
	}

	@Override
	@Transactional
	public Task update(UpdateTaskCommand command) {
		Task existing = requireOwnTask(command.userId(), command.taskId());
		requireOwnListIfPresent(command.userId(), command.listId());
		List<Tag> tags = resolveOwnedTags(command.userId(), command.tagIds());

		Task updated = existing.update(command.title(), command.description(),
				command.status(), command.priority(), command.dueDate(),
				command.listId(), tags);
		return taskRepository.save(updated);
	}

	@Override
	@Transactional
	public void delete(UUID userId, UUID taskId) {
		requireOwnTask(userId, taskId);
		taskRepository.deleteById(taskId);
	}

	private Task requireOwnTask(UUID userId, UUID taskId) {
		return taskRepository.findByIdAndUserId(taskId, userId)
				.orElseThrow(() -> new ResourceNotFoundException("Task not found: " + taskId));
	}

	private void requireOwnListIfPresent(UUID userId, UUID listId) {
		if (listId != null) {
			listRepository.findByIdAndUserId(listId, userId)
					.orElseThrow(() -> new ResourceNotFoundException("List not found: " + listId));
		}
	}

	private List<Tag> resolveOwnedTags(UUID userId, List<UUID> tagIds) {
		return tagIds.stream()
				.map(tagId -> tagRepository.findByIdAndUserId(tagId, userId)
						.orElseThrow(() -> new ResourceNotFoundException(
								"Tag not found: " + tagId)))
				.toList();
	}
}
