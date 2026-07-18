package com.smarttodo.adapter.in.web.dto;

import java.time.Instant;
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
		Instant createdAt,
		Instant updatedAt) {

	public static TaskResponse from(Task task) {
		return new TaskResponse(task.id(), task.title(), task.description(), task.status(),
				task.priority(), task.dueDate(), task.createdAt(), task.updatedAt());
	}
}
