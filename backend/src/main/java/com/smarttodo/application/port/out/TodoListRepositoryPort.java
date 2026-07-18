package com.smarttodo.application.port.out;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.domain.model.TodoList;

public interface TodoListRepositoryPort {

	TodoList save(TodoList list);

	List<TodoList> findAllByUserId(UUID userId);

	Optional<TodoList> findByIdAndUserId(UUID listId, UUID userId);

	void deleteById(UUID listId);
}
