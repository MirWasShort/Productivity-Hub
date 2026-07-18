package com.smarttodo.domain.model;

import java.time.Instant;
import java.util.UUID;

/**
 * A task owned by a user. Pure domain object: no framework imports.
 */
public record Task(
		UUID id,
		UUID userId,
		String title,
		String description,
		TaskStatus status,
		TaskPriority priority,
		Instant dueDate,
		Instant createdAt,
		Instant updatedAt) {

	public static Task createNew(UUID userId, String title, String description,
			TaskPriority priority, Instant dueDate) {
		Instant now = Instant.now();
		return new Task(UUID.randomUUID(), userId, title, description,
				TaskStatus.TODO, priority == null ? TaskPriority.MEDIUM : priority,
				dueDate, now, now);
	}

	public Task update(String title, String description, TaskStatus status,
			TaskPriority priority, Instant dueDate) {
		return new Task(id, userId, title, description, status, priority, dueDate,
				createdAt, Instant.now());
	}
}
