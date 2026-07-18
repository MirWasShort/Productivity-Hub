package com.smarttodo.adapter.in.web.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;

public record TaskResponse(
		UUID id,
		String title,
		String description,
		TaskStatus status,
		TaskPriority priority,
		Instant dueDate,
		UUID listId,
		List<TagResponse> tags,
		Instant createdAt,
		Instant updatedAt) {

	public static TaskResponse from(Task task) {
		return new TaskResponse(task.id(), task.title(), task.description(), task.status(),
				task.priority(), task.dueDate(), task.listId(),
				task.tags().stream().map(TagResponse::from).toList(),
				task.createdAt(), task.updatedAt());
	}
}
