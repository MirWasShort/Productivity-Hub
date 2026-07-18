package com.smarttodo.application.service;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.in.TodoListUseCases;
import com.smarttodo.application.port.out.TodoListRepositoryPort;
import com.smarttodo.domain.model.TodoList;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Same scoping discipline as tasks: a foreign list is a 404, never a
 * 403 — no existence leak.
 */
@Service
public class TodoListService implements TodoListUseCases {

	private final TodoListRepositoryPort repository;

	public TodoListService(TodoListRepositoryPort repository) {
		this.repository = repository;
	}

	@Override
	@Transactional(readOnly = true)
	public List<TodoList> list(UUID userId) {
		return repository.findAllByUserId(userId);
	}

	@Override
	@Transactional
	public TodoList create(CreateListCommand command) {
		return repository.save(
				TodoList.createNew(command.userId(), command.name(), command.color()));
	}

	@Override
	@Transactional
	public TodoList update(UpdateListCommand command) {
		TodoList existing = requireOwnList(command.userId(), command.listId());
		return repository.save(existing.update(command.name(), command.color()));
	}

	@Override
	@Transactional
	public void delete(UUID userId, UUID listId) {
		requireOwnList(userId, listId);
		repository.deleteById(listId);
	}

	private TodoList requireOwnList(UUID userId, UUID listId) {
		return repository.findByIdAndUserId(listId, userId)
				.orElseThrow(() -> new ResourceNotFoundException("List not found: " + listId));
	}
}
