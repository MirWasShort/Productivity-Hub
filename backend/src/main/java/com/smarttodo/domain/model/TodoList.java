package com.smarttodo.domain.model;

import java.time.Instant;
import java.util.UUID;

/**
 * A user-defined bucket for tasks. Pure domain object.
 */
public record TodoList(
		UUID id,
		UUID userId,
		String name,
		String color,
		int position,
		Instant createdAt,
		Instant updatedAt) {

	public static TodoList createNew(UUID userId, String name, String color) {
		Instant now = Instant.now();
		return new TodoList(UUID.randomUUID(), userId, name, color, 0, now, now);
	}

	public TodoList update(String name, String color) {
		return new TodoList(id, userId, name, color, position, createdAt, Instant.now());
	}
}
