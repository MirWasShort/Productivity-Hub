package com.smarttodo.domain.model;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * A task owned by a user. Pure domain object: no framework imports.
 * May belong to at most one list and carry any number of tags.
 */
public record Task(
		UUID id,
		UUID userId,
		String title,
		String description,
		TaskStatus status,
		TaskPriority priority,
		Instant dueDate,
		UUID listId,
		List<Tag> tags,
		Instant createdAt,
		Instant updatedAt) {

	public Task {
		tags = tags == null ? List.of() : List.copyOf(tags);
	}

	public static Task createNew(UUID userId, String title, String description,
			TaskPriority priority, Instant dueDate) {
		Instant now = Instant.now();
		return new Task(UUID.randomUUID(), userId, title, description,
				TaskStatus.TODO, priority == null ? TaskPriority.MEDIUM : priority,
				dueDate, null, List.of(), now, now);
	}

	public Task withListAndTags(UUID listId, List<Tag> tags) {
		return new Task(id, userId, title, description, status, priority, dueDate,
				listId, tags, createdAt, updatedAt);
	}

	public Task update(String title, String description, TaskStatus status,
			TaskPriority priority, Instant dueDate) {
		return new Task(id, userId, title, description, status, priority, dueDate,
				listId, tags, createdAt, Instant.now());
	}

	public Task update(String title, String description, TaskStatus status,
			TaskPriority priority, Instant dueDate, UUID listId, List<Tag> tags) {
		return new Task(id, userId, title, description, status, priority, dueDate,
				listId, tags, createdAt, Instant.now());
	}
}
