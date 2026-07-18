package com.smarttodo.application.port.in;

import java.util.List;
import java.util.UUID;

import com.smarttodo.domain.model.TodoList;

/**
 * Driving port for list management. One interface for the four
 * operations: they are trivial CRUD with shared scoping rules, and the
 * per-operation ceremony of the task ports would add nothing here.
 */
public interface TodoListUseCases {

	List<TodoList> list(UUID userId);

	TodoList create(CreateListCommand command);

	TodoList update(UpdateListCommand command);

	void delete(UUID userId, UUID listId);

	record CreateListCommand(UUID userId, String name, String color) {
	}

	record UpdateListCommand(UUID userId, UUID listId, String name, String color) {
	}
}
