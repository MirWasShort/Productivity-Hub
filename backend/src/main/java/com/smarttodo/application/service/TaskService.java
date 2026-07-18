package com.smarttodo.application.service;

import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.PageResult;
import com.smarttodo.application.port.in.CreateTaskUseCase;
import com.smarttodo.application.port.in.DeleteTaskUseCase;
import com.smarttodo.application.port.in.GetTaskUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase.TaskQuery;
import com.smarttodo.application.port.in.UpdateTaskUseCase;
import com.smarttodo.application.port.out.TaskRepositoryPort;
import com.smarttodo.domain.model.Task;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Every operation is scoped to the authenticated user: a task that exists
 * but belongs to someone else is indistinguishable from a missing one
 * (404, never 403 — no existence leak).
 */
@Service
public class TaskService implements CreateTaskUseCase, GetTaskUseCase, ListTasksUseCase,
		UpdateTaskUseCase, DeleteTaskUseCase {

	private final TaskRepositoryPort taskRepository;

	public TaskService(TaskRepositoryPort taskRepository) {
		this.taskRepository = taskRepository;
	}

	@Override
	@Transactional
	public Task create(CreateTaskCommand command) {
		Task task = Task.createNew(command.userId(), command.title(), command.description(),
				command.priority(), command.dueDate());
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
		Task updated = existing.update(command.title(), command.description(),
				command.status(), command.priority(), command.dueDate());
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
}
